var express = require('express');
var router = express.Router();
var firebase = require('firebase');
var nodemailer = require('nodemailer');

router.post('/', function(req, res) {
    console.log(req.body)
    var transporter = nodemailer.createTransport({
        host: "smtp-mail.outlook.com", // hostname
        secureConnection: false, // TLS requires secureConnection to be false
        port: 587, // port for secure SMTP
        auth: {
            user: "testqlearning@outlook.com",
            pass: //password here
        },
        tls: {
            ciphers:'SSLv3'
        }
    });

    var mailOptions = {
        from: 'testqlearning@outlook.com', // sender address
        to: 'panawaken@gmail.com', // list of receivers
        subject: req.body.subject, // Subject line
        html: req.body.content
    };
    
    transporter.sendMail(mailOptions, function(error, info){
        if(error){
            console.log(error);
            res.status(500).end();
        }else{
            console.log('Message sent: ' + info.response);
            res.status(200).end();
        };
    });

});

module.exports = router;



