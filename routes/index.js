var express = require('express');
var router = express.Router();
var firebase = require('firebase');

router.get('/', function(req, res, next) {
  res.render('index');
});

router.get('/profile', isAuthenticated, function(req, res, next){
	console.log(req.body);
	res.render('profile', { userInfo: req.body });
});

function isAuthenticated (req, res, next) {
	var user = firebase.auth().currentUser;
	if (user !== null) {
	req.user = user;
	next();
	} else {
	res.redirect('/login');
	}
}

module.exports = router;



