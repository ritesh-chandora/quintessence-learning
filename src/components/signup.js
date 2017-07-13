import React, { Component } from 'react';

export default class Signup extends Component { 
	render () {
		return ( 
			<div className="container">
			<div className="col-sm-6 col-sm-offset-3">
			    <h1>Sign Up</h1>
			        <div className="form-group">
			            <label>Email</label>
			            <input type="text" className="form-control" name="email"></input>
			        </div>
			        <div className="form-group">
			            <label>Password</label>
			            <input type="password" className="form-control" name="password"></input>
			        </div>
			        <button type="submit" className="btn btn-warning btn-lg">Sign Up</button>
			    <hr></hr>
			    <p>Already have an account? <a href="/login">Login</a>.</p>
			    <p>Or go <a href="/">home</a>.</p>
				</div>
			</div>
			);
	}
}