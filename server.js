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

var exphbs = require('express-handlebars');

var app = express();

var firebase = require('firebase');
var config = {
    apiKey: "AIzaSyAyMljTvlnQh3VpGPOkGVxErzCBFWzRwoE",
    authDomain: "test-project-692ad.firebaseapp.com",
    databaseURL: "https://test-project-692ad.firebaseio.com",
    projectId: "test-project-692ad",
    storageBucket: "test-project-692ad.appspot.com",
    messagingSenderId: "53496239189"
  };

firebase.initializeApp(config); 

app.use(express.static(path.resolve(__dirname, 'build')));

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
app.use('/login', login);
app.use('/signup', signup);

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

module.exports = app;
