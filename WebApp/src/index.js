import React from 'react'
import ReactDOM from 'react-dom'
import { Redirect, Switch, Route, BrowserRouter } from 'react-router-dom'
import Login from './components/login'
import Signup from './components/signup'
import Console from './components/console'
import firebase from 'firebase'

class Main extends React.Component {
  constructor(props){
    super(props);
    this.state = {
      loggedIn: false
    }

 /*    var config = {
    apiKey: "AIzaSyAyMljTvlnQh3VpGPOkGVxErzCBFWzRwoE",
    authDomain: "test-project-692ad.firebaseapp.com",
    databaseURL: "https://test-project-692ad.firebaseio.com",
    projectId: "test-project-692ad",
    storageBucket: "test-project-692ad.appspot.com",
    messagingSenderId: "53496239189"
  };

  firebase.initializeApp(config);  */
  
  var config = {
    apiKey: "AIzaSyCkifZrvBhkt9kM4sfE7sdAZuu7QPR5R5E",
    authDomain: "test-commvault.firebaseapp.com",
    databaseURL: "https://test-commvault.firebaseio.com",
    projectId: "test-commvault",
    storageBucket: "test-commvault.appspot.com",
    messagingSenderId: "604044529089"
  };
  
firebase.initializeApp(config); 

    this.toggleLoginState = this.toggleLoginState.bind(this);
  }

  toggleLoginState(){
    this.setState({
      loggedIn: !this.state.loggedIn
    });
  }

  render() {
    return( this.state.loggedIn !== null ? 
    <Switch>
      <Route exact path='/' render={() => (
          this.state.loggedIn ? (<Redirect to="/profile"/>) : (<Login toggleLogin={this.toggleLoginState}/>)
        )}/>
      <Route exact path='/login' render={() => (
          this.state.loggedIn ? (<Redirect to="/profile"/>) : (<Login toggleLogin={this.toggleLoginState}/>)
        )}/>
      <Route exact path='/signup' render={() => (
          this.state.loggedIn ? (<Redirect to="/profile"/>) : (<Signup/>)
        )}/>
      <Route path='/profile' 
             render={() => (
                this.state.loggedIn ? (<Console toggleLogin={this.toggleLoginState}/>) : (<Redirect to="/login"/>)
             )} 
             />
           />
      <Route render={
        function() {
          return (<p> Not Found </p>)
        }
      }/>
    </Switch> : null)
  }
}

const Root = () => (
    <BrowserRouter>
      <Main />
    </BrowserRouter>
)

ReactDOM.render(<Root/>, document.getElementById('root'))