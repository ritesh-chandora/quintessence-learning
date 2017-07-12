var express = require('express');
var router = express.Router();
var firebase = require('firebase');

//TODO need to reroute user if not logged in

router.get('/create', function(req, res, next) {
	res.render('create.ejs', {message: null});
});

router.post('/create', function(req, res, next){
	message = create(req.body.question, req.body.tags)
	res.render('create.ejs', {message: message});
});

function create(question, tags){
  //creates two refs for the database, and then the questions collection
  var root = firebase.database().ref(); 
  var qref = root.child('Questions');	
  //checks if current user is signed in
  if(firebase.auth().currentUser){
    //pushes object into the questions collection
    qref.push({text:question,tag:tags});
    return 'Question created successfully!'
  }
  else {
    return 'Error: User not logged in!'
  }
}

module.exports = router;
