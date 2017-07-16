import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import axios from 'axios';
import '../css/console.css'

class QuestionTable extends Component {
    constructor(props){
        super(props);
        this.state = {
            questions: [],
            filterText: ""
        }
    }

    componentDidMount(){
        axios.get('/profile/read')
            .then((response) => {
                console.log(response.data.questions);
                this.setState({questions: response.data.questions});
            }).catch((error) => {
                console.log(error)
            });
    }

    render(){   
        return(
            <div className="col-md-offset-1 col-md-6">
            <h1>Questions</h1>
                <ul>
                {this.state.questions.map((question, index) => {
                  return (
                    <li className="list" key={index}>
                      {question.text}
                    </li>
                    )
                })}
                </ul>
            </div>
        )
    }

}

class CreateTagsBox extends Component {
    constructor(props) {
        super(props);
        this.state = {
            message: null,
            tag: ""
        }
        this.handleTagsChange = this.handleTagsChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }
}

class CreateQuestionBox extends Component { 
    constructor(props){
        super(props);
        this.state = {
            message: null,
            question: "",
            tags: ""
        }

        this.handleQuestionChange = this.handleQuestionChange.bind(this);
        this.handleTagsChange = this.handleTagsChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    //handle create
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
        <div className="col-md-offset-1 col-md-3">
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

class Console extends Component {

    componentDidMount(){
        if (typeof(this.props.location.state) !== 'undefined') {
            axios.post('/login', {
                email: this.props.location.state.email,
                password: this.props.location.state.password
            }).catch((error) => {
                this.props.history.goBack();
            })
        }
    }

    render() {
        return (
            <div className="container container-padding">
            <div className="row">
                    <QuestionTable/>
                    <CreateQuestionBox/>
            </div>
            </div>
            )
    }
}

export default withRouter(Console)