import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import '../css/console.css'
import CreateQuestionBox from './create'
import QuestionTable from './questiontable'
import Menu from './dropdown'
import firebase from 'firebase'

class Console extends Component {
    constructor(props){
        super(props);
        this.state={
            ascending: false,
            questions: [],
            tags: []
        }
        this.getTags = this.getTags.bind(this);
        this.getQuestions = this.getQuestions.bind(this);
        this.toggleAscending = this.toggleAscending.bind(this);
    }

    componentDidMount(){
        this.getQuestions();
        this.getTags();
    }

    toggleAscending(){
        //make sure the calls are synced
        this.setState({ascending: !this.state.ascending}, 
            () => this.getQuestions());    
    }

    getTags(){
        var root = firebase.database().ref();
          var tagRef = root.child('Tags');
          var tags = [];
          tagRef.once('value', (snap) =>{
             snap.forEach((child) => {
               tags.push(child.key);
             })
            this.setState({
                tags: tags
            })
          });
    }

    getQuestions() {
        var ascending = this.state.ascending;
          var root = firebase.database().ref();
          var qref = root.child('Questions');
          //instantiates question list to be returned
          var qlist = [];
            //orders the questions in time order descending and then then listens for values
            qref.orderByKey().once('value',(snap) => {
              //iterates through each value in the snap
              snap.forEach((snap) =>
              {
                //grabs the text, tags, created by, key
                var taglist=[];
                var key= snap.key;
                var text =snap.child('Text').val();
                var tags = snap.child('Tags');
                var created = snap.child('Created_By').val();
                tags.forEach(function(tag)
                {
                  taglist.push(tag.val());
                });
                //makes a list out of those elements
                var sublist = {
                  text: text,
                  taglist: taglist,
                  key:key,
                  created: created
                };

                //pushes into the question list
                if (ascending === true) {
                  qlist.push(sublist);
                } else {
                  qlist.unshift(sublist);
                }
              });
        this.setState({
            questions: qlist
        })
        });
    }

    render() {
        return (
            <div className="container container-padding">
                <div className="row">
                    <div className="col-md-offset-10 col-md-2 text-right">
                        <Menu toggleLogin={this.props.toggleLogin}/>
                    </div>
                </div>
                <div className="row">
                    <div className="col-md-8">
                        <QuestionTable questions={this.state.questions} 
                                       ascending={this.state.ascending}
                                       getQuestions={this.getQuestions}
                                       toggleAscending={this.toggleAscending}
                                       tagRefresh={this.getTags} 
                                       tags={this.state.tags} />
                    </div>
                    <div className="col-md-4">
                        <CreateQuestionBox questions={this.state.questions} 
                                           tags={this.state.tags} 
                                           tagRefresh={this.getTags} 
                                           getQuestions={this.getQuestions}/>
                    </div>
                </div>
            </div>
            )
    }
}

export default withRouter(Console)