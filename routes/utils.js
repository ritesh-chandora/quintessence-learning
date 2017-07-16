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

router.get('/read', function(req, res, next){
  //root and questions refs
  var root = firebase.database().ref();
  var qref = root.child('Questions');
  //instantiates question list to be returned
  var qlist = [];
  //checks if user is logged in
  if(firebase.auth().currentUser){
    //orders the questions in time order descending and then then listens for values
    qref.orderByKey().on('value',function(snap) {
      //iterates through each value in the snap
      snap.forEach(function(snap)
      {
        //grabs the text, tags, created by, key
        var taglist=[];
        var key= snap.key;
        var text =snap.child('Text').val();
        var tags = snap.child('Tags');
        var created = snap.child('Created_By').val();
        tags.forEach(function(tag)
        {
          taglist.push(tag.val());
        });
        //makes a list out of those elements
        var sublist = new Array(text,taglist,key,created);

        console.log(sublist);
        //pushes into the question list
        qlist.push({
          text: text,
          taglist: taglist,
          key: key,
          created: created
        });
      });
    });
  }
  res.send({questions: qlist});
});


module.exports = router;
