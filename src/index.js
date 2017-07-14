import React from 'react'
import ReactDOM from 'react-dom'
import { Switch, Route, BrowserRouter } from 'react-router-dom'
import Home from './components/home'
import Login from './components/login'
import Signup from './components/signup'
import Console from './components/console'

const Main = () => (
    <Switch>
      <Route exact path='/' component={Home}/>
      <Route exact path='/login' component={Login}/>
      <Route exact path='/signup' component={Signup}/>
      <Route path='/profile' component={Console}/>
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