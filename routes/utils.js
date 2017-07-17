var express = require('express');
var router = express.Router();
var firebase = require('firebase');

/**
 *  BASIC CRUD OPERATIONS ON QUESTIONS
 */

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
  // if(firebase.auth().currentUser){
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
        //pushes into the question list
        qlist.push({
          text: text,
          taglist: taglist,
          key: key,
          created: created
        });
      });
    });
  // }
  res.send({questions: qlist});
});

router.post('/delete', function(req, res, next){
  //establishes refs
  var root = firebase.database().ref();
  var qref = root.child('Questions');

  //questionKey is the variable that holds the key for the question you are trying to delete
  var questionKey = req.body.key;
  //userKey is the current users unique ID
  var userKey = firebase.auth().currentUser.uid;
  console.log(questionKey);
  //checks if the question you are trying to delete is created by the current user
  qref.child(questionKey).child('Created_By').once('value',function(snap){
    var question_create = snap.val();

    if(userKey === question_create) {
    //removes the question
    qref.child(questionKey).remove(function(err){
      if (err) {
        console.log(err);
        res.status(400).send({message: 'Question Deletion Error'});
      } else {
        console.log('Question Deleted');
        res.status(200).end();
      }
    });
  } else {
    console.log('Question was not created by current user');
    res.status(400).send({message: 'You did not create this question!'});
  }
  
  });
  
});

router.post('/update', function(req, res, next){
  var root = firebase.database().ref();
  var qref = root.child('Questions');
  //question key is the unique question key you are updating
  var questionKey = req.body.key;
  //userkey is the curret logged in users unique ID
  var userKey = firebase.auth().currentUser.uid;
  //newText is the text you are updating the question with
  var newText = req.body.newText;
  //newTags is the list of tags you are updating the question with
  var newTags = req.body.newTags;
  //checks if the question you're trying to update was created by the current user
  qref.child(questionKey).child('Created_By').once('value',function(snap){
    var question_create = snap.val();
    if (userKey === question_create) {
    //updates the question text
    qref.child(questionKey).update({Text:newText});
    //removes old tags
    qref.child(questionKey).child('Tags').remove(function(err){
      if (err){
        console.log(err);
        res.status(400).send({message: 'Unable to update tags.'});
      } else {
        console.log('Tags deleted');
      }
    })
    //pushes new tags
    var len = newTags.length;
    for (i=0;i<len;i++){
      qref.child(questionKey).child('Tags').push(newTags[i]);
    }
    res.status(200).end();
  } else {
    console.log('Question was not created by current user');
    res.status(400).send({message: 'You did not create this question!'});
  }
  });
});

/**
 * TAG MANIPULATION
 */

router.get('/tags', function(req, res, next){
  var root = firebase.database().ref();
  var tagRef = root.child('Tags');
  var tags = [];
  tagRef.once('value',function(snap){
     snap.forEach(function(child){
      console.log(child)
       tags.push(child.key);
     })
    res.send({tags: tags});
  });
}); 

module.exports = router;
