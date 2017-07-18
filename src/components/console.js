import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import axios from 'axios';
import '../css/console.css'
import CreateQuestionBox from './create'
import QuestionTable from './questiontable'

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