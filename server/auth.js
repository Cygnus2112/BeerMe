var jwt = require('jwt-simple');
var secret = require('./utilities').token.secret;
var scope = require('./utilities').token.scope;

module.exports = {
  checkUser : function(req, res, next) {
    if(!req.headers['x-access-token']) {
      res.sendStatus(500);
    }

    var decodedToken = jwt.decode(req.headers['x-access-token'], secret)

    if(decodedToken.scope === scope) {
      if(req.query) {
        req.query.username = decodedToken.username;
      } else {
        req.body.username = decodedToken.username;
      }
      
      next();
    } else {
      res.sendStatus(500);
    }
},

authenticateUser : function(id, username, res, req){
    var payload = {id: id, username: username, scope: scope};
    var token = jwt.encode(payload, secret);

    res.set('token', token);
    res.json({token: token});
  }
}