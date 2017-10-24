import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import '../css/console.css'
import { EditButton, DeleteButton } from './buttons'
import firebase from 'firebase'
import Multiselect from 'react-widgets/lib/Multiselect'
import 'react-widgets/dist/css/react-widgets.css';
import { FormGroup,ControlLabel,FormControl,Modal,Button,Col,Form,Label,ListGroup,ListGroupItem } from 'react-bootstrap';

class QuestionTable extends Component {
    constructor(props){
        super(props);
        this.state = {
            filterText: "",
            filterTags: [],
            filterMsg: "Filter",
			message:null,
			showEditQuestionBox:false,
			showFilterBox:false,
			editQuestionText:"",
			editQuestionTag:"",
			editQuestionID:null
        }

        this.handleAddition = this.handleAddition.bind(this);
        this.deleteQuestion = this.deleteQuestion.bind(this);
        this.handleSubmitEdit = this.handleSubmitEdit.bind(this);
        this.handleFilterTextChange = this.handleFilterTextChange.bind(this);
        this.handleFilterTagChange = this.handleFilterTagChange.bind(this);

		this.closeEditQuestionBox = this.closeEditQuestionBox.bind(this);
		this.handleEditQuestionChange = this.handleEditQuestionChange.bind(this);
		this.handleEditTagsChange = this.handleEditTagsChange.bind(this);
		this.showEditQuestion = this.showEditQuestion.bind(this);
		this.handlePagerCount = this.handlePagerCount.bind(this);

		this.showFilterBox = this.showFilterBox.bind(this);
		this.closeFilterBox = this.closeFilterBox.bind(this);

    }
	
    componentDidMount(){
        this.props.getQuestions();
    }

	handleAddition(tag, allTags){
        this.setState({filterTags: allTags});
    }

    handleFilterTextChange(event){
        this.setState({filterText: event.target.value});
        // this.setState.filterText = event.target.value;
    }

	handleFilterTagChange(filterTags){
		this.setState({filterTags: filterTags});
		// this.setState.filterTags = filterTags;
	}

	handleSubmitFilter(event){
		event.preventDefault();
		var filterMsg = "Questions Filtered By "+ (this.state.filterText ? " Text ["+this.state.filterText+"]" : "" ) + ( Array.isArray(this.state.filterTags) && this.state.filterTags.length > 0 ? " Tags ["+this.state.filterTags.join(', ')+"]" : "");
		this.setState({filterMsg: filterMsg});
		this.closeFilterBox();
	}

	handleClearFilter(event){
		event.preventDefault();
		this.setState({filterMsg: "Filter",filterText:"",filterTags:[]});
		this.closeFilterBox();
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
			// var userKey = firebase.auth().currentUser.uid;
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

	closeEditQuestionBox() {
		this.setState({ showEditQuestionBox: false, editQuestionID:null, editQuestionText:"", editQuestionTag:[], message:null });
	}

	showEditQuestion(text, tags, qkey){
		this.setState({ showEditQuestionBox: true, editQuestionText:text, editQuestionTag:tags, editQuestionID:qkey });
	}

	handleEditQuestionChange(event){
		this.setState({editQuestionText:event.target.value, message: null});
	}

	handleEditTagsChange(questionTags){
		this.setState({editQuestionTag: questionTags, message: null});
	}

	handleSubmitEdit(e){
		var edittags = this.state.editQuestionTag;
		var editQues = this.state.editQuestionText;
		if (editQues.length === 0){
			this.setState({message: "Please enter a question!"});
		}
		else if (edittags.length === 0){
			this.setState({message: "Please enter tags!"});
		}
		else {
			var root = firebase.database().ref();
			var qref = root.child('Questions');
			//question key is the unique question key you are updating
			var questionKey = this.state.editQuestionID;
			//userkey is the curret logged in users unique ID
			// var userKey = firebase.auth().currentUser.uid;

			//checks if the question you're trying to update was created by the current user
			qref.child(questionKey).child('Created_By').once('value',(snap) => {
				//updates the question text
				qref.child(questionKey).update({Text:editQues});
				//removes old tags
				qref.child(questionKey).child('Tags').remove((err) => {
					if (err){
						console.log(err);
						window.alert('Unable to update tags. ');
					}
					else {
						console.log('Tags deleted');
					}
				});
				//pushes new tags
				var len = edittags.length;
				for (var i=0;i<len;i++){
					qref.child(questionKey).child('Tags').push(edittags[i]);
				}
				this.props.tagRefresh();
				this.props.getQuestions();
				this.closeEditQuestionBox()
			});
		}
	}

	handlePagerCount(event){
		this.props.handlePagerCount(event);
	}

	showFilterBox(){
		this.setState({showFilterBox: true});
	}

	closeFilterBox(){
		this.setState({showFilterBox: false});
	}

    render(){
		const message = this.state.message === null ?
                        (<div></div>) :
                        this.state.success === true ?
                            <div className="alert alert-success"> {this.state.message} </div> :
                            (<div className="alert alert-danger"> {this.state.message} </div>);
		let filteredQuestions = this.props.questions.filter(
            (question) => {
				if(this.state.filterMsg === "Filter" || this.state.showFilterBox == true) return true;
                var inTextFilter = question.text.toLowerCase().indexOf(this.state.filterText.toLowerCase()) !== -1;
                var inTagFilter = this.state.filterTags.every(function(val) { return question.taglist.indexOf(val) !== -1; });
                return inTagFilter && inTextFilter;
            }
        );
        return(
            <div>
				<h2>Questions</h2>
				<div> <span>  <button className="option"  onClick={this.showFilterBox}> <i className="fa fa-filter" aria-hidden="true"></i> {this.state.filterMsg}  </button> </span>
				<span className="floatright"> Rows count: <select onChange={this.handlePagerCount}> <option value="5">5</option> <option value="10">10</option> <option value="20">20</option> <option value="50">50</option>  <option value="100">100</option> <option value="500">500</option> </select></span>
                </div>
                <ListGroup>
				{filteredQuestions.map((question, index) => {
                  return (
                    <ListGroupItem header={question.text} className="liste" key={index}>
					  <span style={{fontSize:10, color:"gray"}}>Count: {question.qCount}</span> {question.taglist.map((tags, tagIndex) => { return( <Label bsStyle="primary" style={{margin:"0px 2px"}} key={tagIndex}>{tags}</Label> )} )}
                      <span>
                      <DeleteButton qkey={question.key} delete={this.deleteQuestion}/>
                      <EditButton qkey={question.key} text={question.text} tags={question.taglist} edit={this.showEditQuestion}/>
                      </span>
                    </ListGroupItem>
                    )
                })}
                </ListGroup>

				<Modal show={this.state.showEditQuestionBox} onHide={this.closeEditQuestionBox}>
				  <Modal.Header closeButton>
					<Modal.Title>Edit Question</Modal.Title>
				  </Modal.Header>
				  <Modal.Body>
					<div>
					<h3> Edit a question </h3>
					{message}
					<div className="form-group">
						<label>Question</label>
						<textarea type="text" className="form-control" value={this.state.editQuestionText} onChange={this.handleEditQuestionChange}></textarea>
						<div>
							<FormGroup controlId="formControlsSelectMultiple">
							  <ControlLabel>Tags</ControlLabel>
								<Multiselect
								  data={this.props.tags}
								  textField='name'
								  caseSensitive={false}
								  minLength={1}
								  filter = 'contains'
								  onChange={this.handleEditTagsChange}
								  defaultValue={this.state.editQuestionTag}
								/>
							</FormGroup>
						</div>
						<button onClick={(e)=> {this.handleSubmitEdit(e);}} type="submit" className= "btn btn-primary btn-lg">  Update </button>
					</div>
					</div>
				  </Modal.Body>
				  <Modal.Footer>
					<Button onClick={ this.closeEditQuestionBox}>Close</Button>
				  </Modal.Footer>
				</Modal>

				<Modal show={this.state.showFilterBox} onHide={this.closeFilterBox}>
				  <Modal.Header closeButton>
					<Modal.Title>Edit Question</Modal.Title>
				  </Modal.Header>
				  <Modal.Body>
					<div>
					<h3> Filter Questions </h3>
					{message}
					<Form horizontal onSubmit={this.handleSubmitDelete}>
						<FormGroup controlId="filterText">
						  <Col sm={3}>
							 <ControlLabel>Filter by text:</ControlLabel>
						  </Col>
						  <Col sm={8}>
							<FormControl placeholder="Enter text" value={this.state.filterText} onChange={this.handleFilterTextChange.bind(this)} />
						  </Col>
						</FormGroup>
						<FormGroup controlId="filterTags">
						 <Col sm={3}>
							 <ControlLabel>Filter by tags:</ControlLabel>
						  </Col>
						  <Col sm={8}>
							<Multiselect
								  data={this.props.tags}
								  textField='name'
								  caseSensitive={false}
								  minLength={1}
								  filter = 'contains'
								  onChange={this.handleFilterTagChange}
								  value = {this.state.tags}
								  defaultValue={this.state.filterTags}
								/><br/>
						  </Col>
						</FormGroup>
						<FormGroup controlId="filterBtn">
						<Col sm={3}>
						</Col>
						<Col sm={8}>
							<button onClick={(e)=> {this.handleSubmitFilter(e);}} type="submit" className= "btn btn-primary btn-lg">  Filter </button>
							<button style={{margin:"0px 10px"}} onClick={(e)=> {this.handleClearFilter(e);}} className= "btn btn-danger btn-lg">  Clear </button>
						</Col>
						</FormGroup>
					</Form>
					</div>
				  </Modal.Body>
				  <Modal.Footer>
					<Button onClick={ this.closeFilterBox}>Close</Button>
				  </Modal.Footer>
				</Modal>
            </div>
        );
    }
}

export default withRouter(QuestionTable)