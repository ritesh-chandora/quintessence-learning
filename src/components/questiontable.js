import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import axios from 'axios';
import '../css/console.css'
import Tags from './tags'
import { EditButton, DeleteButton } from './buttons'

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

export default withRouter(QuestionTable)