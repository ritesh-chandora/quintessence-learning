var express = require('express');
var router = express.Router();
var firebase = require('firebase');

router.post('/', function(req, res, next){
	firebase.auth().signInWithEmailAndPassword(req.body.email, req.body.password)
	.then(function(authData){
		res.send({message: "success"});	
	}).catch(function(err){
 		console.log(err);
		res.send({message: err.message});
 	});
});

router.get('/status', function(req, rest,next){
    var user = firebase.auth().currentUser
    var loggedIn = (user !== null) ? true : false;
    res.send({loggedIn: loggedIn});
});

module.exports = router;
