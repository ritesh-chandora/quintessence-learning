import React from 'react'
import ReactDOM from 'react-dom'
import { Redirect, Switch, Route, BrowserRouter } from 'react-router-dom'
import axios from 'axios'
import Home from './components/home'
import Login from './components/login'
import Signup from './components/signup'
import Console from './components/console'

function requireAuth() {
  console.log("hello")
  var loggedIn = false;
  axios.get('/status')
    .then((response) => {
      loggedIn = response.data.loggedIn;
    })
    .catch((error) => { 
      loggedIn = false;
    });
    console.log(loggedIn)
    return loggedIn;
}

const Main = () => (
    <Switch>
      <Route exact path='/' component={Home}/>
      <Route exact path='/login' component={Login}/>
      <Route exact path='/signup' component={Signup}/>
      <Route path='/profile' render={() => (
        requireAuth() ? (<Console/>) : (<Redirect to="/login"/>)
        )}/>
      <Route render={
        function() {
          return (<p> Not Found </p>)
        }
      }/>
    </Switch>
)

const Root = () => (
    <BrowserRouter>
      <Main />
    </BrowserRouter>
)

ReactDOM.render(<Root />, document.getElementById('root'))