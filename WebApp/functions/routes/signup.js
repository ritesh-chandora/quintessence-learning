var express = require('express');
var router = express.Router();
var firebase = require('firebase');

router.post('/', function(req, res, next){
    console.log(req.body)
    var email = req.body.email
    var password = req.body.password

    var root = firebase.database().ref();
    var userRef = root.child('Users');
    var currentQ = 0;
    var joinDate = firebase.database.ServerValue.TIMESTAMP;
    var name = req.body.name
    var trial = true;
    var type = "user";
    var uid = req.body.uid;
    userRef.child(uid).set(
    {
        Current_Question:currentQ,
        Email:email,
        Join_Date:joinDate,
        Name:name,
        Trial:trial,
        Type:type,
        UID:uid
    });
    res.status(200).end();
});


module.exports = router;
