import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import axios from 'axios';
import firebase from 'firebase'

class Signup extends Component { 
	constructor(props){
		super(props);
		this.state = {
			message: null,
			email : "",
			password: ""
		};
		this.handleEmailChange = this.handleEmailChange.bind(this);
		this.handlePasswordChange = this.handlePasswordChange.bind(this);
		this.handleSubmit = this.handleSubmit.bind(this);
	}

	//handle login
	handleSubmit(event){
		if (this.state.email.length === 0){
			this.setState({message: "Please enter an email!"});
		}
		else if (this.state.password.length === 0){
			this.setState({message: "Please enter a password!"});
		} else {
			var email = this.state.email
			var password = this.state.password
			firebase.auth().createUserWithEmailAndPassword(email, password).then(() =>{
			    var root = firebase.database().ref();
  				var userRef = root.child('Users');
			    var uid = firebase.auth().currentUser.uid;
			    var joinDate=firebase.database.ServerValue.TIMESTAMP;
			    userRef.child(uid).set(
			    {
			    	Current_Question:0,
				    Email:email,
				    Join_Date:joinDate,
				    Name:"name",
				    Trial:false,
				    Type:"none",
				    UID:uid
			    })
			  }).catch((error) => {
			    console.log(error)
			    this.setState({
			    	message:error
			    })
			  });
			
		}
		event.preventDefault();
	}

	handleEmailChange(event){
		this.setState({email: event.target.value});
	}


	handlePasswordChange(event){
		this.setState({password: event.target.value});
	}

	render () {
		const message = this.state.message === null ? (<div></div>) : (<div className="alert alert-danger"> {this.state.message} </div>);
		return ( 			
			<div className="container">
			<div className="col-sm-6 col-sm-offset-3">
			    <h1>Sign Up</h1>
			    	{message}
			    <form onSubmit={this.handleSubmit}>
			        <div className="form-group">
			            <label>Email</label>
			            <input type="text" className="form-control" onChange={this.handleEmailChange}></input>
			        </div>
			        <div className="form-group">
			            <label>Password</label>
			            <input type="password" className="form-control" onChange={this.handlePasswordChange}></input>
			        </div>
			        <button type="submit" className="btn btn-warning btn-lg">Sign Up</button>
			    </form>
			    <hr></hr>
			    <p>Already have an account? <a href="/login">Login</a>.</p>
			    <p>Or go <a href="/">home</a>.</p>
				</div>
			</div>
			);
	}
}

export default withRouter(Signup)