import React, { Component } from 'react';
import axios from 'axios';

class Create extends Component { 
    constructor(props){
        super(props);
        this.state = {
            message: null,
            question: "",
            tags: "",
            success: null
        }

        this.handleQuestionChange = this.handleQuestionChange.bind(this);
        this.handleTagsChange = this.handleTagsChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    componentDidMount(){
        if (typeof(this.props.location.state) != 'undefined') {
            axios.post('/login', {
                email: this.props.location.state.email,
                password: this.props.location.state.password
            }).catch((error) => {
                this.props.history.goBack();
            })
        }
    }

    //handle login
    handleSubmit(event){
        if (this.state.question.length === 0){
            this.setState({message: "Please enter a question!"});
        }
        else if (this.state.tags.length === 0){
            this.setState({message: "Please enter tags!"});
        } else {
            axios.post('/profile/create', {
                question: this.state.question,
                tags: this.state.tags
            }).then((response) => {
                console.log(response.data.message)
                if (response.data.message === 'success'){
                     this.setState({
                        message: "Created successfully!",
                        success: true,  
                        question: "", 
                        tags: "", 
                    })
                } else {
                    this.setState({
                        message: response.data.message,
                        success: false
                    });
                }
            }).catch((error) => {
                this.setState({message: "Unable to connect to signup server!"});
            })
        }
        event.preventDefault();
    }

    handleQuestionChange(event){
        this.setState({question: event.target.value});
    }


    handleTagsChange(event){
        this.setState({tags: event.target.value});
    }

    render() {
        const message = this.state.message === null ? 
                        (<div></div>) : 
                        this.state.success === true ? 
                            <div className="alert alert-success"> {this.state.message} </div> :
                            (<div className="alert alert-danger"> {this.state.message} </div>);
        return (
        <div className="container">
        <div className="col-md-offset-2 col-md-8">
            <h1> Add a question </h1>
            {message}
            <form onSubmit={this.handleSubmit}>
                <div className="form-group">
                    <label>Question</label>
                    <input type="text" className="form-control" onChange={this.handleQuestionChange}></input>
                    <label>Tags</label>
                    <input type="text" className="form-control" onChange={this.handleTagsChange}></input>
                </div>
                <button type="submit" className="btn btn-warning btn-lg">Add</button>
            </form>
        </div>
    </div>)
    }
}

export default class Console extends Component {
    render() {
        return (
            <Create location={this.props.location}/>
            )
    }
}