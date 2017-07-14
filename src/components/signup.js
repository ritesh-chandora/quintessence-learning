import React, { Component } from 'react';
import axios from 'axios';

export default class Signup extends Component { 
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
			axios.post('/signup', {
				email: this.state.email,
				password: this.state.password
			}).then((response) => {
				console.log(response.data.message)
				if (response.data.message === 'success'){
					this.props.history.push('/profile', {
						email: this.state.email,
						password: this.state.password
					});
				} else {
					this.setState({message: response.data.message});
				}
			}).catch((error) => {
				this.setState({message: "Unable to connect to signup server!"});
			})
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