var express = require('express');
var router = express.Router();
var firebase = require('firebase');

router.get('/status', function(req, res){
    var user = firebase.auth().currentUser;
    res.send({loggedIn: (user !== null)});
});

router.post('/', function(req, res, next){
	firebase.auth().signInWithEmailAndPassword(req.body.email, req.body.password)
	.then(function(authData){
		res.send({message: "success"});	
	}).catch(function(err){
 		console.log(err);
		res.send({message: err.message});
 	});
});

router.post('/logout', function(req, res, next){
    firebase.auth().signOut().then(()=>{
        res.send(200).end();
    }).catch((error)=>{
        res.send({message:error});
    });
});

module.exports = router;
