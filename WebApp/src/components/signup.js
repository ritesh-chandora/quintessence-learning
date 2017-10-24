import React, { Component } from 'react';
import {withRouter} from "react-router-dom";
// import axios from 'axios';
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
				window.location = "/";
				this.setState({
			    	message:"Account Create Successfully."
			    })
			  }).catch((error) => {
			    this.setState({
			    	message:error.message
			    });
			  });

		}
		event.preventDefault();
	}

	handleEmailChange(event){
		this.setState({email: event.target.value, message:null});
	}


	handlePasswordChange(event){
		this.setState({password: event.target.value, message:null});
	}

	render () {
		const message = this.state.message === null ? (<div></div>) : (<div className="alert alert-danger"> {this.state.message} </div>);
		return (
			<div className="container">
			<div className="col-md-4 col-md-offset-4" style={{marginTop:100}}>
                <div className="login-panel panel panel-default">
                    <div className="panel-heading">
                        <h3 className="panel-title">Register</h3>
                    </div>
					{message}
                    <div className="panel-body">
                        <form onSubmit={this.handleSubmit}>
                            <fieldset>
								<img src="./img/peoplegraphic.png" alt="Family Huddles" style={{width:150, display:"block", margin:"10px auto 15px"}}/>
                                <div className="form-group">
									<label className="control-label" htmlFor="email">Email</label>
                                    <input className="form-control" placeholder="Email Address" name="email" type="email"  value={this.state.email} onChange={this.handleEmailChange}/>
                                </div>
                                <div className="form-group">
									<label className="control-label" htmlFor="email">Password</label>
                                    <input className="form-control" placeholder="Password" name="password" type="password"   value={this.state.password} onChange={this.handlePasswordChange} />
                                </div>
                                <button href="index.html" className="btn btn-lg btn-success btn-block">Sign Up</button>
								<div className="text-center">
								  <p>Already have an account? <a href="/login">Login</a>.</p>
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

export default withRouter(Signup)