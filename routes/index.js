var express = require('express');
var router = express.Router();
var firebase = require('firebase');

var config = {
    apiKey: "AIzaSyAyMljTvlnQh3VpGPOkGVxErzCBFWzRwoE",
    authDomain: "test-project-692ad.firebaseapp.com",
    databaseURL: "https://test-project-692ad.firebaseio.com",
    projectId: "test-project-692ad",
    storageBucket: "test-project-692ad.appspot.com",
    messagingSenderId: "53496239189"
  };
// firebase.initializeApp(config); 

// router.use(function (req, res, next) {
//   var user = firebase.auth().currentUser;
//   if (user !== null) {
//     req.user = user;
//     res.redirect('/profile', {data: req.user});
//   } else {
//     res.redirect('/');
//   }
//  });

router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.post('/login', function(req, res, next){
	console.log(req.body)
	firebase.auth().signInWithEmailAndPassword(req.body.email, req.body.password).then(function(authData){
		res.redirect('/profile');	
	}).catch(function(err){
 		console.log(err);
		res.redirect('/');
 	});
});

router.get('/profile', function(req, res, next){
	res.render('profile', { title: 'Express' });
});


module.exports = 
// 
// }, 
router;



