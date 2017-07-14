var express = require('express');
var router = express.Router();
var firebase = require('firebase');

router.post('/create', function(req, res, next){
	message = create(req.body.question, req.body.tags).catch((error)=>{
    console.log(error);
  })
	res.send({message: message});
});

function create(question, tags){
  console.log("ahhh")
  //creates two refs for the database, and then the questions collection
  var root = firebase.database().ref(); 
  var qref = root.child('Questions');	
  //checks if current user is signed in
  console.log("huh??")
  console.log(firebase.auth())
  if(firebase.auth().currentUser){
    //pushes object into the questions collection
    qref.push({text:question,tag:tags});
    console.log("what")
    return 'success'
  }
  else {
    console.log("rejected")
    return 'Error: User not logged in!'
  }
}

module.exports = router;
