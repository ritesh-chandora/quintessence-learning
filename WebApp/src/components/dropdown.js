import React, { Component } from 'react';
import '../css/console.css'
import CSSTransitionGroup from 'react-transition-group/CSSTransitionGroup';
import axios from 'axios'

class Menu extends Component {
    constructor(props){
        super(props);

        this.state = {
            active:false
        }
        this.toggleMenu = this.toggleMenu.bind(this);
        this.passReset = this.passReset.bind(this);
        this.logout = this.logout.bind(this);
    }

    toggleMenu() {
        this.setState({
            active: !this.state.active
        });
    }

    logout(){
        axios.post('/login/logout', {}).then((response)=>{
            if(response.status === 200){
                this.props.loginStatus();
            } else {
                window.alert(response.data.error);
            }
        });
    }

    passReset(){
        let email = window.prompt("Please input your email!");
        if (email !== null){}
           axios.post('/profile/pass', {
            email: email
           }).then((response)=>{
                if(response.status === 200){
                    window.alert("Password email sent!")
                } else {
                    window.alert(response.data.error);
                }
            }); 
        }

    render() {
    let menu;
    console.log("help")
    if(this.state.active) {
      menu = <div>
                <ul>
                  <button className="option" onClick={this.passReset}>Change Password</button>
                  <button className="option" onClick={this.logout}>Logout </button>
                </ul>
              </div>
    } else {
      menu = "";
    }
    return (
    <div id = "menu">
        <button className="btn btn-warning btn-lg" onClick = { this.toggleMenu }>Settings</button>
        <CSSTransitionGroup transitionName = "menu" transitionEnterTimeout={1000} transitionLeaveTimeout={1000}>
        {menu}
      </CSSTransitionGroup>
    </div>
    )
  }

}



export default Menu