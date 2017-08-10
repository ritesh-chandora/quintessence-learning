import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import '../css/console.css'
import Tags from './tags'
import firebase from 'firebase'

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
            
            //see if there are any new tags
            var newTags = this.state.tags.filter((tagObj) => {return this.props.tags.indexOf(tagObj) === -1})
            var needRefreshTags = newTags.length !== 0;
            //creates two refs for the database, and then the questions collection
              var root = firebase.database().ref(); 
              var qref = root.child('Questions');
              var tagRef = root.child('Tags');
              var count = null;
              root.child('Count').once("value").then((snapshot) => {
                count = snapshot.val() 
                var question = this.state.question
                var qtag = tags
                //pushes object into the questions collection
                var key = root.child('Questions').push().key;
                var user = firebase.auth().currentUser.uid
                var ctime = firebase.database.ServerValue.TIMESTAMP;
                qref.child(key).set({Text:question,Key:key,Created_By:user,cTime:ctime,count:count});
                var len = qtag.length;
                for (var i=0;i<len;i++){
                qref.child(key).child('Tags').push(qtag[i]);
                tagRef.child(qtag[i]).push(key);
              }
              root.child('Count').set(count+1)

              this.setState({
                        message: "Created successfully!",
                        question: "", 
                        tags: "", 
                        success: true
                    });
                    if (needRefreshTags) {
                        this.props.tagRefresh();
                    }
                    this.props.getQuestions();
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