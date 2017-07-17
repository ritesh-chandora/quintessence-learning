var express = require('express');
var router = express.Router();
var firebase = require('firebase');

router.get('/', function(req, res, next){
  var root = firebase.database().ref();
  var tagRef = root.child('Tags');
  var tags = [];
  tagRef.once('value',function(snap){
     snap.forEach(function(child){
       tags.push(child.key);
     })
    res.send({tags: tags});
  });
}); 

module.exports = router;
