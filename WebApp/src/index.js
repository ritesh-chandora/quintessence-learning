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
    this.getLoginStatus = this.getLoginStatus.bind(this);
  }
  
  componentDidMount(){
    this.getLoginStatus()
  }

  getLoginStatus(){
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
      <Route exact path='/login' render={() => (
          this.state.loggedIn ? (<Redirect to="/profile"/>) : (<Login loginStatus={this.getLoginStatus}/>)
        )}/>
      <Route exact path='/signup' render={() => (
          this.state.loggedIn ? (<Redirect to="/profile"/>) : (<Signup/>)
        )}/>
      <Route path='/profile' 
             render={() => (
                this.state.loggedIn ? (<Console loginStatus={this.getLoginStatus}/>) : (<Redirect to="/login"/>)
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