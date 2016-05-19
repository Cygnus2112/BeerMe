var mongoose = require('mongoose');
var dbURI = require('./utilities').dbURI;

var db = {};

//******DATABASE SET UP

db.dbURI = dbURI;
mongoose.connect(db.dbURI);
db.Schema = mongoose.Schema;
db.userSchema = new db.Schema ({
  username: { type: String, required: true, unique: true },
  password: { type: String },
  wishList: {},
  dislikes: {},
  email: { type: String }
});

db.User = mongoose.model('User', db.userSchema);

db.User.find(function (err, users) {
  if (err) return console.error(err);
  console.log(users);
})

module.exports = db;

