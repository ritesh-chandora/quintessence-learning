import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import '../css/console.css'
import Tags from './tags'
import { EditButton, DeleteButton } from './buttons'
import firebase from 'firebase'

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
                var root = firebase.database().ref();
                  var qref = root.child('Questions');
                  //question key is the unique question key you are updating
                  var questionKey = qkey;
                  //userkey is the curret logged in users unique ID
                  var userKey = firebase.auth().currentUser.uid;
                  //newText is the text you are updating the question with
                  var newText = newText;
                  //newTags is the list of tags you are updating the question with
                  var newTags = newTags;
                  //checks if the question you're trying to update was created by the current user
                  qref.child(questionKey).child('Created_By').once('value',(snap) => {
                    //updates the question text
                    qref.child(questionKey).update({Text:newText});
                    //removes old tags
                    qref.child(questionKey).child('Tags').remove((err) => {
                      if (err){
                        console.log(err);
                        window.alert('Unable to update tags.');
                      } else {
                        console.log('Tags deleted');
                      }
                    })
                    //pushes new tags
                    var len = newTags.length;
                    for (var i=0;i<len;i++){
                      console.log(newTags[i])
                      qref.child(questionKey).child('Tags').push(newTags[i]);
                    }
                    this.props.tagRefresh();
                    this.props.getQuestions();
                  });
            }
        }
    }

    deleteQuestion(qkey){ 
        var isOK = window.confirm('Are you sure you want to delete this question?');
        if (isOK){
            //establishes refs
              var root = firebase.database().ref();
              var qref = root.child('Questions');
              //questionKey is the variable that holds the key for the question you are trying to delete
              var questionKey = qkey;
              //userKey is the current users unique ID
              var userKey = firebase.auth().currentUser.uid;
              console.log(questionKey);
              //checks if the question you are trying to delete is created by the current user
              qref.child(questionKey).child('Created_By').once('value',(snap) => {
                //removes the question
                qref.child(questionKey).remove((err) => {
                  if (err) {
                    console.log(err);
                    window.alert('Question Deletion Error');
                  } else {
                    console.log('Question Deleted');
                    this.props.getQuestions();
                  }
                });
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

        let ascendingText = this.props.ascending ? "Oldest to Newest" : "Newest to Oldest";

        return(
            <div>
            <h1>Questions</h1>
                <span> Filter by text: </span>
                <input type="text" value={this.state.filterText} onChange={this.updateFilter.bind(this)}/> 
                
                <span> Filter by tags: </span>
                <span>
                    <Tags sourceTags={this.props.tags} 
                          onRemove={this.handleAddition}
                          onAdd={this.handleAddition}/>
                </span>
                Order by <button className="option" onClick={this.props.toggleAscending}>{ascendingText}</button>
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