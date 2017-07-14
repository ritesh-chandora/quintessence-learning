import React from 'react'
import ReactDOM from 'react-dom'
import { Redirect, Switch, Route, BrowserRouter } from 'react-router-dom'
import axios from 'axios'
import Home from './components/home'
import Login from './components/login'
import Signup from './components/signup'
import Console from './components/console'

class Main extends React.Component {
  constructor(props){
    super(props);
    this.state = {
      loggedIn: null
    }
  }

  componentDidMount(){
    axios.get('/login/status')
    .then((response) => {
      this.setState({loggedIn: response.data.loggedIn});
    })
    .catch((error) => { 
      return false;
    });
  }

  render() {
    return( this.state.loggedIn !== null ? 
    <Switch>
      <Route exact path='/' render={() => (
          this.state.loggedIn ? (<Redirect to="/profile"/>) : (<Home/>)
        )}/>
      <Route exact path='/login' component={Login}/>
      <Route exact path='/signup' component={Signup}/>
      <Route path='/profile' render={() => (
          this.state.loggedIn ? (<Console/>) : (<Redirect to="/login"/>)
        )}/>
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

ReactDOM.render(<Root />, document.getElementById('root'))