import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import axios from 'axios';
import '../css/console.css'
import Tags from './tags'

const DeleteButton = (props) => {
    const deleteQuestion = () => { 
        var isOK = window.confirm('Are you sure you want to delete this question?');
        if (isOK){
            axios.post('/profile/delete', {
                key: props.qkey
            })
            .then((response)=>{
                window.location.reload();
            })
            .catch((error)=> {
                window.alert(error.response.data.message)
            });
        }
    }

    return (<button onClick={deleteQuestion} className="option">
                <i className="fa fa-trash" aria-hidden="true"></i>
            </button>)
};

const EditButton = (props) => {
    const editQuestion = () => {
        console.log(props.tags)
        var newText = "";
        while (newText === ""){
            newText = window.prompt('Modify the question (Tags on next prompt):', props.text);
        }
        if (newText !== null) {
            var newTags = "";
            while (newTags === ""){
                newTags = window.prompt('Modify tags (separate by comma):', props.tags);
            }
            if (newTags !== null) {
                newTags = newTags.split(',');
                axios.post('/profile/update', {
                    key: props.qkey,
                    newText: newText,
                    newTags: newTags
                })
                .then((response)=>{
                    window.location.reload();
                })
                .catch((error)=> {
                    window.alert(error.response.data.message)
                });
                }
        }
    }

    return (<button onClick={editQuestion} className="option">
                <i className="fa fa-pencil" aria-hidden="true"></i>
            </button>)
};

class QuestionTable extends Component {
    constructor(props){
        super(props);
        this.state = {
            questions: [],
            tags: [],
            filterText: "",
            filterTags: [],
            loaded: null
        }

        this.handleAddition = this.handleAddition.bind(this);
    }

    componentDidMount(){
        axios.get('/profile/read')
            .then((response) => {
                this.setState({
                    questions: response.data.questions,
                });
                axios.get('/profile/tags')
                    .then((response) => {
                        var tags = response.data.tags.map((tag) => {
                            return {label: tag};
                        })
                        this.setState({
                            tags: tags,
                            loaded: true
                        });
                    }).catch((error) => {
                        window.alert(error)
                    });
            }).catch((error) => {
                window.alert(error)
        });
    }

    handleAddition(tag, allTags){
        console.log(allTags);
        this.setState({filterTags: allTags});
    }

    updateFilter(event){
        this.setState({filterText: event.target.value});
    }

    render(){   
        let filteredQuestions = this.state.questions.filter(
            (question) => {
                var inTextFilter = question.text.toLowerCase().indexOf(this.state.filterText.toLowerCase()) !== -1;
                var inTagFilter = this.state.filterTags.every(function(val) { return question.taglist.indexOf(val.label) !== -1; });
                return inTagFilter && inTextFilter;
            }
        );
        return(
            this.state.loaded !== null ? (
            <div>
            <h1>Questions</h1>
                <span> Filter by text: </span>
                <input type="text" value={this.state.filterText} onChange={this.updateFilter.bind(this)}/> 
                
                <span> Filter by tags: </span>
                <span>
                
                    <Tags sourceTags={this.state.tags} 
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
                      <DeleteButton qkey={question.key}/>
                      <EditButton qkey={question.key} text={question.text} tags={question.taglist}/>
                      </span>
                    </li>
                    )
                })}
                </ul>
            </div>) 
            : null
        )
    }
}

export default withRouter(QuestionTable)