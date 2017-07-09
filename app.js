var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');

var index = require('./routes/index');
var users = require('./routes/users');

var exphbs = require('express-handlebars');

var app = express();

var firebase = require('firebase');

// Initialize Firebase for the application
var config = {
    apiKey: "AIzaSyAyMljTvlnQh3VpGPOkGVxErzCBFWzRwoE",
    authDomain: "test-project-692ad.firebaseapp.com",
    databaseURL: "https://test-project-692ad.firebaseio.com",
    projectId: "test-project-692ad",
    storageBucket: "test-project-692ad.appspot.com",
    messagingSenderId: "53496239189"
  };
firebase.initializeApp(config); 

// view engine setup
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.engine('.htm', exphbs({
  defaultLayout: 'main',
  extname: '.htm',
  helpers: {
    toJSON: function(object) {
      return JSON.stringify(object);
    },
    cap: function(s){
      return em.createTitle(s);
    },
    eq: function(a, b) {
      return a === b;
    },
    summary: function(str, len) {
      if (str.length > len) {
        return str.substr(0, len) + '..';
      }
      return str;
    },
    cnt: function(str) {
      return (typeof str !== 'undefined' && str !== '') ? str.split(",").length : 0;
    },
    ne: function(v1, v2) {
      return v1 !== v2;
    },
    lt: function(v1, v2) {
      return v1 < v2;
    },
    gt: function(v1, v2) {
      return v1 > v2;
    },
    lte: function(v1, v2) {
      return v1 <= v2;
    },
    gte: function(v1, v2) {
      return v1 >= v2;
    },
    and: function(v1, v2) {
      return v1 && v2;
    },
    or: function(v1, v2) {
      return v1 || v2;
    },
    fmtForEmpty: function(str) {
      return ('' + str).trim() === '' ? 'None' : str;
    },
    nlToBr: function(str) {
      if (('' + str).trim() === '') {
        return 'None';
      }
      return str.replace(new RegExp('\n', 'g'), '<br>');
    }
  }
}));
app.set('view engine', 'htm');

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', index);
app.use('/users', users);

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
  res.render('error');
});

app.listen(3001, function() {
  console.log('Up and running!');
});

module.exports = app;
