import React, { Component } from 'react';

export default class Home extends Component { 
	render () {
		return ( 
			<div className="container">
				<div class="col-sm-6 col-sm-offset-3">
				    <h1> Welcome! </h1>
				    <p>You can:</p>
				    <a className="btn btn-info btn-lg" href="/login">Login</a>
				    <a className="btn btn-info btn-lg" href="/signup">Sign Up</a>
				</div>
			</div>
			);
	}
}
