var express = require('express');
var router = express.Router();
var firebase = require('firebase');

router.post('/', function(req, res, next){
	firebase.auth().createUserWithEmailAndPassword(req.body.email, req.body.password)
	.then(function(authData){
		res.send({message: "success"});   
	}).catch(function(err){
 		console.log(err);
		res.send({message: err.message});
 	});
});


module.exports = router;
