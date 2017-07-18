import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import axios from 'axios';
import '../css/console.css'
import Tags from './tags'

//need this or else filter tags will spawn 
const emptyList = []

class CreateQuestionBox extends Component { 
    constructor(props){
        super(props);
        this.state = {
            message: null,
            question: "",
            tags: "",
            success: null,
            placeholdertags: []
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
            var tags = this.state.tags.map((tagObj) => { return(tagObj.label) });
            axios.post('/profile/create', {
                question: this.state.question,
                tags: tags
            }).then((response) => {
                console.log(response.data.message)
                if (response.data.message === 'success'){
                     this.setState({
                        message: "Created successfully!",
                        question: "", 
                        tags: "", 
                        success: true
                    })
                    this.props.getQuestions();
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

    handleTagsChange(tag, allTags){
        this.setState({tags: allTags});
    }

    render() {
        const message = this.state.message === null ? 
                        (<div></div>) : 
                        this.state.success === true ? 
                            <div className="alert alert-success"> {this.state.message} </div> :
                            (<div className="alert alert-danger"> {this.state.message} </div>);
        return (
        <div>
            <h1> Add a question </h1>
            {message}
            <div className="form-group">
                <label>Question</label>
                <input type="text" className="form-control" value={this.state.question} onChange={this.handleQuestionChange}></input>
                <label>Tags</label>
                <div>
                    <Tags ref={(instance) => {this.tagsComp = instance}}
                          defTags={emptyList}
                          sourceTags={this.props.tags} 
                          onRemove={this.handleTagsChange}
                          onAdd={this.handleTagsChange}/>
                </div>
            </div>
            <button onClick={(e)=> {
                        this.handleSubmit(e); 
                        this.tagsComp.resetTags()
                    }} 
                    type="submit" 
                    className="btn btn-warning btn-lg">Add</button>
        </div>)
    }
}


export default withRouter(CreateQuestionBox)