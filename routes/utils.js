var express = require('express');
var router = express.Router();
var firebase = require('firebase');

router.post('/create', function(req, res, next){
  var root = firebase.database().ref(); 
  var qref = root.child('Questions'); 
  //checks if current user is signed in
  var user = firebase.auth().currentUser
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
    res.send({message:"success"});
  }
  else {
    res.send({message:'Error: User not logged in!'});
  }
});

module.exports = router;
