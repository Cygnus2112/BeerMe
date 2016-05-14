var jwt = require('jwt-simple');
var secret = "super secret";
var scope = "full access";

module.exports = {
  checkUser : function(req, res, next) {
    if(!req.headers['x-access-token']) {
      res.sendStatus(500);
    }

    var decodedToken = jwt.decode(req.headers['x-access-token'], secret)

    if(decodedToken.scope === scope) {
       //req.query.id = decodedToken.id;
      req.query.username = decodedToken.username;
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