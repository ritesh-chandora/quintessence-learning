var functions = require('firebase-functions')
var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');

var index = require('./routes/index');
var login = require('./routes/login');
var signup = require('./routes/signup');
var utils = require('./routes/utils');
var tags = require('./routes/tags');
var email = require('./routes/email');

var exphbs = require('express-handlebars');

var app = express();

var firebase = require('firebase');
  
var config = {
    apiKey: "AIzaSyCkifZrvBhkt9kM4sfE7sdAZuu7QPR5R5E",
    authDomain: "test-commvault.firebaseapp.com",
    databaseURL: "https://test-commvault.firebaseio.com",
    projectId: "test-commvault",
    storageBucket: "test-commvault.appspot.com",
    messagingSenderId: "604044529089"
  };
  
firebase.initializeApp(config); 

app.use(express.static(path.resolve(__dirname, '../build')));

app.set('views', __dirname + '/views');
app.set('view engine', 'pug');

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());

// app.use('/', index);
app.use('/profile', utils);
app.use('/profile/tags', tags);
app.use('/login', login);
app.use('/signup', signup);
app.use('/email', email)

app.get('*', (req, res) => {
    console.log("wtf");
    res.sendFile(path.resolve(__dirname, 'build', 'index.html'));
});

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  // res.render('error');
});

app.listen(3001, function() {
  console.log('Up and running!');
});

exports.api = functions.https.onRequest(app)