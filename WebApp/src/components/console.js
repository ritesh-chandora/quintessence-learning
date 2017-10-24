import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import '../css/console.css'
import CreateQuestionBox from './create'
import TagsOp from './questionTags'
import QuestionTable from './questiontable'
import firebase from 'firebase'
import { Navbar,Nav,NavItem,Pager,Popover,OverlayTrigger,Button,ListGroup,ListGroupItem } from 'react-bootstrap';
import 'react-widgets/dist/css/react-widgets.css';

class Console extends Component {
    constructor(props){
        super(props);
        this.state={
			filterText: "",
            filterTags: [],
            questions: [],
            tags: [],
			showQuestionBox: false,
			showEditQuestionBox: false,
			editQuestion_question:"",
			editQuestion_tags:[],
			showTagBox: false,
			pagerCount:6,
			pagerStartKey:null,
			pagerEndKey:null,
			showPagerNext:true,
			showPagerPrev:true
        }
        this.getTags = this.getTags.bind(this);
        this.getQuestions = this.getQuestions.bind(this);
        this._parseGetQuestions = this._parseGetQuestions.bind(this);

        this.handleNavigation = this.handleNavigation.bind(this);
		this.closeCreateQuestionBox = this.closeCreateQuestionBox.bind(this);
        this.openCreateQuestionBox = this.openCreateQuestionBox.bind(this);

		this.closeTagBox = this.closeTagBox.bind(this);
        this.openTagBox = this.openTagBox.bind(this);

		this.closeEditQuestionBox = this.closeEditQuestionBox.bind(this);
        this.openEditQuestionBox = this.openEditQuestionBox.bind(this);

		this.handlePagerNext = this.handlePagerNext.bind(this);
		this.handlePagerPrev = this.handlePagerPrev.bind(this);
		this.handlePagerCount = this.handlePagerCount.bind(this);

		this.handleFilterTextChange = this.handleFilterTextChange.bind(this);
        this.handleFilterTagChange = this.handleFilterTagChange.bind(this);
		
		this.passReset = this.passReset.bind(this);
        this.logout = this.logout.bind(this);
    }

    componentDidMount(){
        this.getQuestions();
        this.getTags();
    }

	handleFilterTextChange(event){
        this.setState({filterText: event.target.value});
    }

	handleFilterTagChange(filterTags){
		this.setState({filterTags: filterTags});
	}

    getTags(){
        var root = firebase.database().ref();
        var tagRef = root.child('TagsList');
        var tags = [];
        tagRef.once('value', (snap) =>{
				snap.forEach((child) => {
				tags.push(child.val());
			});
            this.setState({tags: tags});
		});
    }

	handleNavigation(selectedKey) {
		if(selectedKey === 1){
			this.openCreateQuestionBox()
		}
		else if(selectedKey === 2){
			this.openTagBox()
		}
	}

	closeCreateQuestionBox() {
		this.setState({ showQuestionBox: false });
	}

	openCreateQuestionBox() {
		this.setState({ showQuestionBox: true });
	}

	closeTagBox() {
		this.setState({ showTagBox: false });
	}

	openTagBox() {
		this.setState({ showTagBox: true });
	}

	closeEditQuestionBox() {
		this.setState({ showEditQuestionBox: false });
	}

	openEditQuestionBox() {
		this.setState({ showEditQuestionBox: true });
	}

	handlePagerCount(event){
		var pagerCount = parseInt(event.target.value, 10) + 1;
		this.setState({pagerCount:pagerCount});
		this.getQuestions(null,pagerCount);
	}

	handlePagerPrev(){
		this.getQuestions("backward");
	}
	
	handlePagerNext(){
		this.getQuestions("forward");
	}

    getQuestions(startFrom, equalTo ) {
		equalTo = (typeof equalTo === "undefined" ? this.state.pagerCount : parseInt(equalTo, 10));

		var root = firebase.database().ref();
		var qref = root.child('Questions');
		//instantiates question list to be returned

        //orders the questions in time order descending and then then listens for values
		if(startFrom == null || this.state.pagerEndKey==null & this.state.pagerStartKey == null ){
			qref.orderByKey().limitToLast(equalTo).once('value',this._parseGetQuestions);
		}
		else if(startFrom === "forward"){
			qref.orderByKey().limitToFirst(equalTo).endAt(this.state.pagerEndKey).once('value',this._parseGetQuestions);
		}
		else if(startFrom === "backward"){
			qref.orderByKey().limitToLast(equalTo).startAt(this.state.pagerStartKey).once('value',this._parseGetQuestions);
		}
	}

	_parseGetQuestions(snap) {
		var qlist = [];
		var totalChild = snap.numChildren();
		var itemsProcessed = 0;

		//iterates through each value in the snap
		snap.forEach((snap) => {
			itemsProcessed++;
			if(itemsProcessed === 1){
				this.setState({pagerEndKey:snap.key});
				// console.log(`Pagecount ${this.state.pagerCount} TotalChild ${totalChild}`);
				if(totalChild === this.state.pagerCount){
					this.setState({showPagerNext:true})
					return;
				}
				else{
					this.setState({showPagerNext:false});
				}
			}
			if(itemsProcessed === totalChild ) {
				this.setState({pagerStartKey:snap.key});
			}

			if(this.state.pagerStartKey === this.state.pagerEndKey){
				this.setState({showPagerPrev:false,showPagerNext:true, pagerStartKey:null, pagerEndKey:null});
			}
			else{
				this.setState({showPagerPrev:true});
			}

			//grabs the text, tags, created by, key
			var taglist=[];
			var key= snap.key;
			var text =snap.child('Text').val();
			var tags = snap.child('Tags');
			var created = snap.child('Created_By').val();
			tags.forEach(function(tag){
				taglist.push(tag.val());
			});
			//makes a list out of those elements
			var sublist = {
				text: text,
				taglist: taglist,
				key:key,
				created: created,
				qCount:snap.child('count').val()
			};

			qlist.unshift(sublist);
		});
		this.setState({questions: qlist})
	}
	
	logout(){
		firebase.auth().signOut().then(()=>{
			this.props.toggleLogin();
		}).catch((error)=>{
			window.alert(error);
		});
    }

    passReset(){
		let email = window.prompt("Please input your email!");
		if (email !== null){
			var auth = firebase.auth();
			auth.sendPasswordResetEmail(email).then(() => {
				window.alert("Password email sent!")
			}).catch(function(error) {
				window.alert(error);
			});
		}
    }

    render() {
		const popoverClickRootClose = (
			  <Popover id="popover-trigger-click-root-close" title="Admin!">
					<ListGroup>
						<ListGroupItem href="#" onClick={this.passReset} >Change Password</ListGroupItem>
						<ListGroupItem href="#" onClick={this.logout} >Logout</ListGroupItem>
					</ListGroup>
			  </Popover>
			);
        return (
			<div id="wrapper">
				<Navbar>
					<Navbar.Header>
						<Navbar.Brand>
							<a href="./profile">Family Huddles</a>
						</Navbar.Brand>
					</Navbar.Header>
					<Nav onSelect={this.handleNavigation}>
						<NavItem eventKey={1} >
							<CreateQuestionBox 
								showQuestionBox={this.state.showQuestionBox}
								closeCreateQuestionBox={this.closeCreateQuestionBox}
								questions={this.state.questions}
								tags={this.state.tags}
								tagRefresh={this.getTags}
								getQuestions={this.getQuestions}/>
						</NavItem>
						<NavItem eventKey={2} href="#">
							<TagsOp
								showTagBox={this.state.showTagBox}
								closeTagBox={this.closeTagBox}
								tags={this.state.tags}
								getQuestions={this.getQuestions}
								tagRefresh={this.getTags}  />
						</NavItem>
							
					</Nav>
					<Nav pullRight>
						<NavItem eventKey={3} href="#" >
							<OverlayTrigger trigger="click" rootClose placement="bottom" overlay={popoverClickRootClose}>
								<span>Setting</span>
							</OverlayTrigger>
						</NavItem>
					</Nav>
				</Navbar>
				<div className="container container-padding">
					<div className="row">
						<div className="col-md-12">
						   <QuestionTable
								questions = {this.state.questions}
								getQuestions = {this.getQuestions}
								toggleAscending = {this.toggleAscending}
								tagRefresh = {this.getTags}
								handlePagerCount = {this.handlePagerCount}
								tags = {this.state.tags}
								/>
							<Pager>
								 { this.state.showPagerPrev ?<Pager.Item onClick={this.handlePagerPrev} previous href="#">&larr; Previous Page</Pager.Item> : null }
								 { this.state.showPagerNext ? <Pager.Item onClick={this.handlePagerNext} next href="#">Next Page &rarr;</Pager.Item> : null }
							</Pager>
						</div>
					</div>
				</div>
            </div>
		)
    }
}

export default withRouter(Console)