import React, { Component } from 'react';
// import {withRouter} from "react-router-dom";
import firebase from 'firebase'
import { FormGroup,ControlLabel,FormControl,Modal,Button,Tab,Col,Form,Row,Nav,NavItem } from 'react-bootstrap';
// import Multiselect from 'react-widgets/lib/Multiselect'
import 'react-widgets/dist/css/react-widgets.css';

class TagsOp extends Component {
    constructor(props){
        super(props);
        this.state = {
			message:null,
			success:false,
            createTagName:"",
			tagToBeDeleted:-1
        }
        this.handleSubmitCreate = this.handleSubmitCreate.bind(this);
        this.handleCreateTagNameChange = this.handleCreateTagNameChange.bind(this);
        this.addNewTag = this.addNewTag.bind(this);
        this.handleSubmitDelete = this.handleSubmitDelete.bind(this);
        this.handleOnChangeTag = this.handleOnChangeTag.bind(this);
    }

    //handle create
    handleSubmit(event){
		console.log(event);
        event.preventDefault();
    }

    handleSubmitCreate(event){
		event.preventDefault();
		console.log(event);

		if(this.state.createTagName === "" || this.state.createTagName.trim().length === 0){
			this.setState({message: "Tag name should not be empty.", success:false});
		}
		else{
			this.addNewTag(this.state.createTagName);
		}
    }

	handleSubmitDelete(event){
		event.preventDefault();
		if(this.state.tagToBeDeleted === "-1" || this.state.tagToBeDeleted === ""){
			this.setState({message: "Please select a Tag.", success:false});
		}
		else{
			this.deleteTag(this.state.tagToBeDeleted);
		}
		return
		/* event.preventDefault();
		console.log(event);

		if(this.state.createTagName == "" || this.state.createTagName.trim().length == 0){
			this.setState({message: "Tag name should not be empty."});
		}
		else{
			this.addNewTag(this.state.createTagName);
		} */
    }

	handleOnChangeTag(event){
		this.setState({tagToBeDeleted: event.target.value,message:null});
	}


	handleCreateTagNameChange(event){
		this.setState({createTagName: event.target.value,message:null});
    }

	addNewTag(value){
		if (value.trim().length===0){//empty
			this.setState({message: "Tag name should not be empty.", success:false});
			return;
		}

		value=value.trim();

		var root = firebase.database().ref();
		var tagRef = root.child('TagsList');

		tagRef.orderByValue().equalTo(value).once("value",snapshot => {
			const userData = snapshot.val();
			if (userData){
				this.setState({
					message: "Tag already present!!.",
					createTagName: "",
					success: false
				});
				this.props.tagRefresh();
			}
			else{
				tagRef.push(value);
				this.setState({
					message: "Tag Created successfully!",
					createTagName: "",
					success: true
				});
				this.props.tagRefresh();
			}
		});
	}

	deleteTag(value){
		var isOK = window.confirm('Are you sure you want to delete this Tag from all question?');
        if (isOK){
			var root = firebase.database().ref();
			var tagRef = root.child('Tags').child(value);
			var qref = root.child('Questions');
			var qTagList = root.child('TagsList');
			var itemsProcessed = 0;
			tagRef.once('value', (snap) =>{
				var totalChild = snap.numChildren();
				if(totalChild === 0){
					//No Task is associated with the Tag.
					this.setState({
						message: "Tag Deleted successfully!",
						tagToBeDeleted: -1,
						success: true
					});
					tagRef.remove((err)=>{
						this.props.tagRefresh();
					});
				}
				else{
					snap.forEach((questionKey, i, arr) => {
						qref.child(questionKey.val()).child('Tags').orderByValue().equalTo(value).once('value',(tagSnap) => {
							tagSnap.forEach((tagKey) => {
								root.child('Questions').child(questionKey.val()).child('Tags').child(tagKey.key).remove((err) => {
									if (err) {
										window.alert('Tag Deletion Error');
									}
									else {
										console.log('Tag Deleted');
										itemsProcessed++;
										if(itemsProcessed === totalChild ) {
											console.log("last child exec");
											tagRef.remove((err)=>{
												this.setState({
													message: "Tag Deleted successfully!",
													tagToBeDeleted: -1,
													success: true
												});
												this.props.tagRefresh();
												this.props.getQuestions();
											});
										}
										else{
											console.log("child "+itemsProcessed);
										}
									}
								});
							});
						});
					});
				}
			})


			qTagList.orderByValue().equalTo(value).once('value',(tagListSnap) => {
				tagListSnap.forEach((tagKey) => {
					console.log(tagKey.val())
					console.log(tagKey.key)
					qTagList.child(tagKey.key).remove((err) => {
						if (err) {
							window.alert('Tag Deletion Error');
						}
						else {
							console.log('Tag Deleted from Tag List ');
						}
					});
				});
			});
		}
	}

    render() {
        const message = this.state.message === null ?
                        (<div></div>) :
                        this.state.success === true ?
                            <div className="alert alert-success"> {this.state.message} </div> :
                            (<div className="alert alert-danger"> {this.state.message} </div>);

		return (
		<div>Add Tags
			<Modal show={this.props.showTagBox} onHide={this.props.closeTagBox}>
          <Modal.Header closeButton>
            <Modal.Title>Tags</Modal.Title>
          </Modal.Header>
          <Modal.Body>

			<Tab.Container id="tabs-with-dropdown" defaultActiveKey="first">
				<Row className="clearfix">
				  <Col sm={12}>
					<Nav bsStyle="tabs">
					  <NavItem eventKey="first">
						Add Tag
					  </NavItem>
					  <NavItem eventKey="second">
						Delete Tag
					  </NavItem>
					</Nav>
				  </Col>
				  <Col sm={12}>
					<Tab.Content animation>
					  <Tab.Pane eventKey="first">
							<br/>
							<h4> Add New Tag </h4>
							<br/>
							<Form horizontal onSubmit={this.handleSubmitCreate}>
							<FormGroup controlId="formAddNewTagInpt">
							  <Col componentClass={ControlLabel} sm={2}>
								Add Tags
							  </Col>
							  <Col sm={9}>
								<FormControl type="text" value={this.state.createTagName} onChange={this.handleCreateTagNameChange} placeholder="Tag Name" />
							  </Col>
							</FormGroup>
							<FormGroup>
							  <Col smOffset={2} sm={9}>
								<Button type="submit" bsStyle="success">
								  Add Tag
								</Button>
							  </Col>
							</FormGroup>
						  </Form>
					  </Tab.Pane>
					  <Tab.Pane eventKey="second">
						<br/>
						<h4> Delete Tags </h4>
						<br/>
						<div>
						<Form horizontal onSubmit={this.handleSubmitDelete}>
						  <FormGroup controlId="formControlsSelect">
						  <Col componentClass={ControlLabel} sm={2}>
							Select Tag
						  </Col>
						  <Col sm={9}>
							<FormControl componentClass="select" placeholder="select"  value={ this.state.tagToBeDeleted} onChange={this.handleOnChangeTag}>
								 <option key="-1" value="-1">Select</option>
								{this.props.tags.map((name,i)=> <option key={i} value={name}>{name}</option>)}
						  </FormControl>
						  </Col>
						</FormGroup>
						<FormGroup>
							<Col smOffset={2} sm={9}>
							<Button type="submit" bsStyle="danger">
							  Delete Tag
							</Button>
							 </Col>
						</FormGroup>
						</Form>
						</div>
					  </Tab.Pane>
					</Tab.Content>
				  </Col>
				</Row>
			</Tab.Container>
			{message}
          </Modal.Body>
          <Modal.Footer>
            <Button onClick={this.props.closeTagBox}>Close</Button>
          </Modal.Footer>
        </Modal>
      </div>
    );
   }
}


export default TagsOp;