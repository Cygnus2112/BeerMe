var express = require('express');
var bodyParser = require('body-parser');
var routes = require('./routes');
var mongoose = require('mongoose');
var app = express();
var db = require('./database');
var cors = require('cors');

app.use(cors());

app.use(function(req,res,next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,POST,PUT');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, x-access-token, Origin, X-Requested-With, Content-Type, Accept');
  res.header('Access-Control-Expose-Headers', 'token');

  next();
});

var port = process.env.PORT || 8080;

app.use(bodyParser.json());

app.use('/', routes);

app.listen(port);

console.log('Listening on port ' + port);

module.exports = app;


