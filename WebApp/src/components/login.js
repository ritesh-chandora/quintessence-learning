import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
import firebase from 'firebase';

class Login extends Component {
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

		event.preventDefault();
		if (this.state.email.length === 0){
			this.setState({message: "Please enter an email!"});
		}
		else if (this.state.password.length === 0){
			this.setState({message: "Please enter a password!"});
		} else {
			firebase.auth().signInWithEmailAndPassword(this.state.email, this.state.password)
			.then((authData) =>{
		        var root = firebase.database().ref();
		        var userref = root.child("Users").child(authData.uid)
		        userref.child("Type").once("value").then( (snapshot) =>{
				  var type = snapshot.val()
		          if (type === "admin") {
		                 this.props.toggleLogin()
		            } else {
		            	this.setState({
		            		password:"",
		            		message:"Not an admin!"
		            	});
		                firebase.auth().signOut();
		            }
		        })
			}).catch((error) =>{
				this.setState({
					password:"",
					message:"Email or Password is incorrect"
				});
		  });
		}
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
				<div className="col-md-4 col-md-offset-4" style={{marginTop:100}}>
					<div className="login-panel panel panel-default">
						<div className="panel-heading">
							<h3 className="panel-title">Please Sign In</h3>
						</div>
						<div className="panel-body">
							{message}
							<form onSubmit={this.handleSubmit}>
								<fieldset>
									<img src="./img/peoplegraphic.png" alt="Family Huddles" style={{width:150, display:"block", margin:"10px auto 15px"}}/>
									<div className="form-group">
										<label className="control-label" htmlFor="email">Email</label>
										<input className="form-control" placeholder="Email Address" name="email" type="email" value={this.state.email} onChange={this.handleEmailChange}/>
									</div>
									<div className="form-group">
										<label className="control-label" htmlFor="email">Password</label>
										<input className="form-control" placeholder="Password" name="password" type="password" value={this.state.password} onChange={this.handlePasswordChange} />
									</div>
									<button href="index.html" className="btn btn-lg btn-success btn-block">Login</button>
									<div className="text-center">
									  <a className="small" href="/signup">Register an Account</a>
									</div>
								</fieldset>
							</form>
						</div>
					</div>
				</div>
				</div>
			);
	}
}
export default withRouter(Login)