import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import axios from 'axios';
import '../css/console.css'
import CreateQuestionBox from './create'
import QuestionTable from './questiontable'
import Menu from './dropdown'

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

    getQuestions() {
        axios.post('/profile/read', {
            ascending: this.state.ascending
        }).then((response) => {
                console.log(response.data)
                this.setState({
                    questions: response.data.questions,
                });
            }).catch((error) => {
                window.alert(error)
        });
    }

    render() {
        return (
            <div className="container container-padding">
                <div className="row">
                    <div className="col-md-offset-10 col-md-2 text-right">
                        <Menu loginStatus={this.props.loginStatus}/>
                    </div>
                </div>
                <div className="row">
                    <div className="col-md-8">
                        <QuestionTable questions={this.state.questions} 
                                       ascending={this.state.ascending}
                                       getQuestions={this.getQuestions}
                                       toggleAscending={this.toggleAscending}
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