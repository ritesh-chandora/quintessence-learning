import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import axios from 'axios';
import '../css/console.css'
import Tags from './tags'

const DeleteButton = (props) => {
    return (<button onClick={() => props.delete(props.qkey)} className="option">
                <i className="fa fa-trash" aria-hidden="true"></i>
            </button>)
};

const EditButton = (props) => {
    return (<button onClick={() => props.edit(props.text, props.tags, props.qkey)} className="option">
                <i className="fa fa-pencil" aria-hidden="true"></i>
            </button>)
};

class QuestionTable extends Component {
    constructor(props){
        super(props);
        this.state = {
            filterText: "",
            filterTags: [],
        }
        this.handleAddition = this.handleAddition.bind(this);
        this.deleteQuestion = this.deleteQuestion.bind(this);
        this.editQuestion = this.editQuestion.bind(this);
        this.updateFilter = this.updateFilter.bind(this);
    }

    componentDidMount(){
        this.props.getQuestions();   
    }

    updateFilter(event){
        this.setState({filterText: event.target.value});
    }

    handleAddition(tag, allTags){
        console.log(allTags);
        this.setState({filterTags: allTags});
    }

    editQuestion(text, tags, qkey) {
        var newText = "";
        while (newText === ""){
            newText = window.prompt('Modify the question (Tags on next prompt):', text);
        }
        if (newText !== null) {
            var newTags = "";
            while (newTags === ""){
                newTags = window.prompt('Modify tags (separate by comma):', tags);
            }
            if (newTags !== null) {
                newTags = newTags.split(',');
                axios.post('/profile/update', {
                    key: qkey,
                    newText: newText,
                    newTags: newTags
                })
                .then((response)=>{
                   this.props.getQuestions();
                })
                .catch((error)=> {
                    window.alert(error.response.data.message)
                });
            }
        }
    }

    deleteQuestion(qkey){ 
        var isOK = window.confirm('Are you sure you want to delete this question?');
        if (isOK){
            axios.post('/profile/delete', {
                key: qkey
            })
            .then((response)=>{
                this.props.getQuestions();    
            })
            .catch((error)=> {
                window.alert(error.response.data.message)
            });
        }
    }

    render(){   
        let filteredQuestions = this.props.questions.filter(
            (question) => {
                var inTextFilter = question.text.toLowerCase().indexOf(this.state.filterText.toLowerCase()) !== -1;
                var inTagFilter = this.state.filterTags.every(function(val) { return question.taglist.indexOf(val.label) !== -1; });
                return inTagFilter && inTextFilter;
            }
        );
        return(
            <div>
            <h1>Questions</h1>
                <span> Filter by text: </span>
                <input type="text" value={this.state.filterText} onChange={this.updateFilter.bind(this)}/> 
                
                <span> Filter by tags: </span>
                <span>
                    <Tags sourceTags={this.props.tags} 
                          onlyFromSource={true} 
                          onRemove={this.handleAddition}
                          onAdd={this.handleAddition}/>
                
                </span>
                <ul>
                {filteredQuestions.map((question, index) => {
                  return (
                    <li className="list" key={index}>
                      {question.text} 
                      <span>
                      <DeleteButton qkey={question.key} delete={this.deleteQuestion}/>
                      <EditButton qkey={question.key} text={question.text} tags={question.taglist} edit={this.editQuestion}/>
                      </span>
                    </li>
                    )
                })}
                </ul>
            </div>
        ); 
    }
}

class CreateQuestionBox extends Component { 
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
        <div>
            <h1> Add a question </h1>
            {message}
            <form onSubmit={this.handleSubmit}>
                <div className="form-group">
                    <label>Question</label>
                    <input type="text" className="form-control" value={this.state.question} onChange={this.handleQuestionChange}></input>
                    <label>Tags</label>
                    <input type="text" className="form-control" value={this.state.tags} onChange={this.handleTagsChange}></input>
                </div>
                <button type="submit" className="btn btn-warning btn-lg">Add</button>
            </form>
        </div>)
    }
}

class Console extends Component {
    constructor(props){
        super(props);
        this.state={
            questions: [],
            tags: []
        }
        this.createTag = this.createTag.bind(this);
        this.getQuestions = this.getQuestions.bind(this);
    }

    componentDidMount(){
        axios.get('/profile/tags')
            .then((response) => {
                var tags = response.data.tags.map((tag) => {
                    return {label: tag};
                })
                this.setState({
                    tags: tags,
                });
            }).catch((error) => {
                window.alert(error)
            });
    }

    createTag(tagName){
        return;
    }

    getQuestions() {
        axios.get('/profile/read')
            .then((response) => {
                this.setState({
                    questions: response.data.questions,
                });
            }).catch((error) => {
                window.alert(error)
        });
    }

    render() {
        console.log(this.state.tags)
        return (
            <div className="container container-padding">
                <div className="row">
                    <div className="col-md-8">
                        <QuestionTable questions={this.state.questions} 
                                       tags={this.state.tags} 
                                       getQuestions={this.getQuestions}/>
                    </div>
                    <div className="col-md-4">
                        <CreateQuestionBox questions={this.state.questions} 
                                           tags={this.state.tags} 
                                           createTag={this.props.createTag} 
                                           getQuestions={this.getQuestions}/>
                    </div>
                </div>
            </div>
            )
    }
}

export default withRouter(Console)