var express = require('express');
var router = express.Router();
var firebase = require('firebase');

router.post('/create', function(req, res, next){
  console.log("hi")
  var root = firebase.database().ref(); 
  var qref = root.child('Questions'); 
  //checks if current user is signed in
  var user = firebase.auth().currentUser
  console.log("what")
  if(user !== null){
    //pushes object into the questions collection
    var key = root.child('Questions').push().key;
    var user = user.uid
    qref.child(key).set({Text:req.body.question,Key:key,Created_By:user});
    var len = req.body.tags.length;
    console.log('k')
    for (i=0;i<len;i++){
      qref.child(key).child('Tags').push(req.body.tags[i]);
    }
    console.log("o");
    res.send({message:"success"});
  }
  else {
    console.log("wah");
    res.send({message:'Error: User not logged in!'});
  }
});

// function test (){
//   return "what";
// }

// function create(question, tags){
//   creates two refs for the database, and then the questions collection
  
// }

module.exports = router;
