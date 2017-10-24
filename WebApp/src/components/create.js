import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import '../css/console.css'
import firebase from 'firebase'
import { FormGroup,ControlLabel,Modal,Button,Checkbox } from 'react-bootstrap';
import Multiselect from 'react-widgets/lib/Multiselect'
import 'react-widgets/dist/css/react-widgets.css';

class CreateQuestionBox extends Component {
    constructor(props){
        super(props);
        this.state = {
            message: null,
            question: "",
            tags: null,
            success: null,
            placeholdertags: []
        }

        this.handleQuestionChange = this.handleQuestionChange.bind(this);
        this.handleTagsChange = this.handleTagsChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    //handle create
    handleSubmit(event){
		console.log(this.state);
        if (this.state.question.length === 0){
            this.setState({message: "Please enter a question!"});
        }
        else if (this.state.tags.length === 0){
            this.setState({message: "Please enter tags!"});
        }
		else {
            var tags = this.state.tags;
            //creates two refs for the database, and then the questions collection
				var root = firebase.database().ref();
				var qref = root.child('Questions');
				var tagRef = root.child('Tags');
				var count = null;

				root.child('Count').once("value").then((snapshot) => {
					count = snapshot.val();
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
						tags: null,
						success: true
					});
					this.props.getQuestions();
				})
        }
        event.preventDefault();
    }

    handleQuestionChange(event){
        this.setState({question: event.target.value, message: null});
    }

	handleTagsChange(questionTags){
        this.setState({tags: questionTags, message: null});
    }

    render() {
        const message = this.state.message === null ?
                        (<div></div>) :
                        this.state.success === true ?
                            <div className="alert alert-success"> {this.state.message} </div> :
                            (<div className="alert alert-danger"> {this.state.message} </div>);
		return (
			<div>
				Add Question
				<Modal show={this.props.showQuestionBox} onHide={this.props.closeCreateQuestionBox}>
					<Modal.Header closeButton>
						<Modal.Title>Add Question</Modal.Title>
					</Modal.Header>
					<Modal.Body>
						<div>
							<h3> Add a question </h3>
							{message}
							<div className="form-group">
								<label>Question</label>
									<textarea type="text" className="form-control" value={this.state.question} onChange={this.handleQuestionChange}></textarea>
									<div>
									<FormGroup controlId="formControlsSelectMultiple">
										<ControlLabel>Tags</ControlLabel>
										<Multiselect
											data={this.props.tags}
											textField='name'
											caseSensitive={false}
											minLength={1}
											filter = 'contains'
											onChange={this.handleTagsChange}
											value = {this.state.tags}
										/>
									</FormGroup>
									<FormGroup>
										<Checkbox> Only for Premium User </Checkbox>
									</FormGroup>
								</div>
							</div>
							<button onClick={(e)=> {this.handleSubmit(e);}} type="submit" className="btn btn-primary btn-lg">Add</button>
						</div>
					</Modal.Body>
					<Modal.Footer>
						<Button onClick={ this.props.closeCreateQuestionBox}>Close</Button>
					</Modal.Footer>
				</Modal>
			</div>
		);
    }
}


export default withRouter(CreateQuestionBox)