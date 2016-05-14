var express = require('express');
var bodyParser = require('body-parser');
var routes = require('./routes');
var mongoose = require('mongoose');
var app = express();
var db = require('./database');
var request = require('request');

var Promise = require('bluebird');

app.use(function(req,res,next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,POST,PUT');
  res.header('Access-Control-Expose-Headers', 'token');

  next();
});

var port = process.env.PORT || 8080;

app.use(bodyParser.json());

app.use('/', routes);

// app.get('/', function(req, res) {
// 	res.end('hey there buddy!');
// })

// app.post('/signup',function(req,res){
// 	var user = new db.User({
//   		username: req.body.username,
//   		password: req.body.password,
//   		wishList: {"8zCFMS": {				
//   			"name": "1687 Brown Ale",
//   			"label": "https://s3.amazonaws.com/brewerydbapi/beer/8zCFMS/upload_mpD3aH-medium.png",
//   			"style": "English-Style Brown Ale"
//   		}},
//   		dislikes: {"placeholder": "tbd"},
//   		email: req.body.email
// 	})

// 	user.save(function (err) {
//   		if (err) {
//     		console.log(err);
//   		} else {
//     		console.log('new user saved to db');
//     		res.json({"response": "new user saved to db"});
//   		}
// 	});
// });

// app.get('/fetchbeers', function(req,res){
// 	var username = req.query.username;
// 	var style = req.query.style;

// 	console.log('username: ', username);

// 	var wishList = {} || req.query.wishList;
// 	var dislikes = {} || req.query.dislikes;

// 	var url = "http://api.brewerydb.com/v2/beers?key=336ad89cea47e683efa68ee5c51f7449&availableId=1&hasLabels=y&order=random&randomCount=10";
	
// 	if(style === "Pilsner") {
// 		style = "Pilsener";
// 	}
// 	console.log("username ", username);
// 	console.log("style ", style);

// 	// do a while search with random setting and keep checking if we don't find beers w/that style

// 	var foundBeers = 0;
// 	var beersFetched = {};

// 	var promiseWhile = function(condition, action) {
//     	var resolver = Promise.defer();

//     	var loop = function() {
//         	if (!condition()) return resolver.resolve();
//         	return Promise.cast(action())
//             	.then(loop)
//             	.catch(resolver.reject);
//     	};
//     	process.nextTick(loop);
//     	return resolver.promise;
// 	};

// 	promiseWhile(function() {
//     		return foundBeers < 2;
// 		}, function() {    			
// 			return new Promise(function(resolve, reject) {     		
//         	request.get(url, function(err, response, body) { 
//         		if(err){
//             	console.log(err);
//         	}
//         	console.log("---------------------");       

//        // separate out into sep file:
//         	var data = JSON.parse(body);

//         	if(data.data[0].style){
//         		data.data.forEach(function(beer){
//         			if(beer.style){
//         				if(beer.style.name.includes(style) &&
//         					!(beer.id in wishList) &&
//         					!(beer.id in dislikes)){
// 							foundBeers++;
// 							beersFetched[beer.id] = {
// 								"name": beer.name,
// 								"label": beer.labels.large,
// 								"style": beer.style.name
// 							}
// 						}
// 					}
//         		})
//     		}

//    //      	for(var i = 0; i < data.data.length; i++){
// 			// 	var beer = data.data[i];

// 			// 	if(beer.style.name.includes(style)){
// 			// 	foundBeers = true;
					

// 			// 	// if(!(beer.id in likes) && !(beer.id in dislikes))

// 			// 		console.log(beer.name);
// 			// 	}
// 			// }
        

//         	console.log("---------------------");   
//         	if(foundBeers >= 2){
//         		console.log(beersFetched);
//         		res.json(beersFetched); 
//         		//res.json(body); 
//         	}

//         	resolve();      
// 		});
//     		});


// 		}).then(function() {
  
//     	console.log("Done");
// 	});
    
// })

// app.get('/wishlist', function(req,res){
// 	var username = req.query.username;
// 	var wishlist;

// 	db.User.findOne({username:username},function(err,user){
// 		if(err){
// 			console.log('err finding user');
// 			res.send(err);
// 		}
		
// 		// user.wishList["8zCFMS"] = {				
//   // 			"name": "1687 Brown Ale",
//   // 			"label": "https://s3.amazonaws.com/brewerydbapi/beer/8zCFMS/upload_mpD3aH-medium.png",
//   // 			"style": "English-Style Brown Ale"
//   // 		};
// 	//	user.markModified('wishList')
// 		// console.log(user.wishList)
		
// 		// user.save(function(err,user){
// 		// 	if(err){
// 		// 		console.log("Error saving wishlist");
// 		// 	}
// 		// 	console.log('updated wishlist ');
// 		// });
// 		wishlist = user.wishList;
// 		res.json(wishlist)
// 	})
// })

// app.post('/wishlist', function(req,res){
// 	var username = req.body.username;
// 	var wishlist = req.body.wishlist;
// 	var dislikes = req.body.dislikes;

// 	console.log('username in POST request:');
// 	console.log(username);
// 	console.log('wishlist in POST request:');
// 	console.log(wishlist);

// 	db.User.findOne({username:username},function(err,user){
// 		if(err){
// 			console.log('err finding user');
// 			res.json({"error": err});
// 		}
// 		wishlist.forEach(function(beer){
// 			user.wishList[beer.id] = {
// 				"name": beer.name,
// 				"style": beer.style,
// 				"label": beer.labelUrl
// 			}
// 			user.markModified('wishList');

// 		});
// 		dislikes.forEach(function(beer){
// 			user.dislikes[beer.id] = {
// 				"name": beer.name,
// 				"style": beer.style,
// 				"label": beer.labelUrl
// 			}
// 			user.markModified('dislikes');
// 		});

		
// 		// user.wishList["8zCFMS"] = {				
//   // 			"name": "1687 Brown Ale",
//   // 			"label": "https://s3.amazonaws.com/brewerydbapi/beer/8zCFMS/upload_mpD3aH-medium.png",
//   // 			"style": "English-Style Brown Ale"
//   // 		};
// 	//	user.markModified('wishList')
// 		// console.log(user.wishList)
		
// 		user.save(function(err,user){
// 			if(err){
// 				console.log("Error saving wishlist and or dislikes");
// 			}
// 			console.log('updated wishlist and dislikes');
// 		});
// 		//wishList = user.wishList;
// 		res.json({"response": "success"});
// 	})
// })

app.listen(port);

console.log('Listening on port ' + port);

module.exports = app;


