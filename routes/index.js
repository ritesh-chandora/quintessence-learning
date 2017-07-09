var express = require('express');
var router = express.Router();
var firebase = require('firebase');

router.get('/', function(req, res) {
  res.render('index.ejs');
});

router.get('/profile', isAuthenticated, function(req, res){
	res.render('profile.ejs', req.body);
});

function isAuthenticated (req, res, next) {
	var user = firebase.auth().currentUser;
	if (user !== null) {
		req.body = {name: user.displayName, email: user.email};
		next();
	} else {
		res.redirect('/login');
	}
}

module.exports = router;



