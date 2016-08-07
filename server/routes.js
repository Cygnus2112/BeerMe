var express = require('express');
var router = express.Router();
var db = require('./database');
var request = require('request');
var Promise = require('bluebird');
var bcrypt = require('bcrypt');
var auth = require('./auth');
var breweryKey = require('./utilities').breweryKey;

router.post('/signup',function(req,res){
	var username = req.body.username,
  		password = req.body.password,
  		email = req.body.email;

  	db.User.findOne({username:username},function(err,user){
  		if(!user){
  			bcrypt.genSalt(10, function(err, salt){
  				bcrypt.hash(password, salt, function(err, hash){
  					var newUser = new db.User({
  						username: username,
  						password: hash,
  						wishList: {},
  						dislikes: {},
  						email: email
					})
					newUser.save(function (err, newlyCreatedUser) {
  						if (err) {
    						console.log(err);
  						} else {
  							var id = newlyCreatedUser["_id"];
            				auth.authenticateUser(id, username, res);
    						console.log('new user saved to db');
  						}
					});
				});
			});
  		} else {
  			res.json({"ERROR" : "username already taken"})
  		}
	});
});

router.post('/login',function(req, res, next) {
  	var username = req.body.username,
  		password = req.body.password;

  	db.User.findOne({username: username}, function(err, user){
  		if(user.username.length){
			bcrypt.compare(password, user.password, function(err, result){
        		if(err) {
          			throw err
        		}
        		if(result) {
          			console.log('success logging in');
          			auth.authenticateUser(user["_id"], username, res, req);
        		} else {
          			console.error('failed logging '+ username +'in!');
          			res.sendStatus(500);
        		}
      		});
    	} else {
      		console.error('user', username, 'not found');
      		res.sendStatus(500);
    	}
	});  			
});

router.get('/fetchbeers', function(req,res){
	var username = req.query.username;
	var style;
	if(!req.query.style) {
		style = "Ale";
		console.log('req.query.style undefined!!!');
	} else {
		style = req.query.style;
	}

	var wishList = {};
	var dislikes = {};
	db.User.findOne({username:username},function(err,user){
		if(err){
			console.log('error finding user in DB');
			res.send(err);
		}
		wishList = user.wishList || {};
		dislikes = req.query.dislikes || {};
	})

	// ------------------

	var url = "http://api.brewerydb.com/v2/beers?key="+breweryKey+"&availableId=1&hasLabels=y&order=random&randomCount=10&withBreweries=y";
	
	if(style === "Pilsner") {
		style = "Pilsener";
	}

	// do a while search with random setting and keep checking if we don't find beers w/that style

	var foundBeers = 0;
	var beersFetched = {};

	var promiseWhile = function(condition, action) {
    	var resolver = Promise.defer();
    	var loop = function() {
        	if (!condition()) return resolver.resolve();
        	return Promise.cast(action())
            	.then(loop)
            	.catch(resolver.reject);
    	};
    	process.nextTick(loop);
    	return resolver.promise;
	};

	promiseWhile(function() {
    		return foundBeers < 2;
		}, function() {    			
			return new Promise(function(resolve, reject) {     		
        		request.get(url, function(err, response, body) { 
        			if(err){
            			console.log("error in fetchbeers: ", err);
        			}
        			console.log("---------------------");       

       // TODO separate out into sep file:
        			var data = JSON.parse(body);

        			if(data.errorMessage) {
        				console.error("BreweryDB error: ", data.errorMessage);
        				res.json(data);
        				return;
        			} else if(data.data[0].style){
        				data.data.forEach(function(beer){
        					if(beer.style){
        						if(beer.style.name.includes(style) &&
        							!(beer.id in wishList) &&
        							!(beer.id in dislikes)){
									foundBeers++;
									beersFetched[beer.id] = {
										"name": beer.name,
										"label": beer.labels.medium,
										"style": beer.style.name,
										"icon": beer.labels.icon,
										"descript": beer.description,
										"abv": beer.abv,
										"brewery": beer.breweries[0].name,
										"website": beer.breweries[0].website
									}
								}
							}
        				})
    				} 

        			console.log("---------------------");   
        			if(foundBeers >= 2){
        				console.log(beersFetched);
        				res.json(beersFetched); 
        			}
        			resolve();      
				});
    		});
		}).then(function() {
    		console.log("Done");
		});  
})


router.get('/wishlist', auth.checkUser, function(req,res){
	var username = req.query.username;
	var wishlist;

	db.User.findOne({username:username},function(err,user){
		if(err){
			console.log('error finding user in DB');
			res.send(err);
		}
		wishlist = user.wishList || {};
		res.json(wishlist)
	})
})

router.post('/wishlist', auth.checkUser, function(req,res){
	var username = req.body.username;
	var wishlist = req.body.wishlist;
	var dislikes = req.body.dislikes;

	db.User.findOne({username:username},function(err,user){
		if(err){
			console.log('err finding user');
			res.json({"error": err});
		}
		wishlist.forEach(function(beer){
			if(!user.wishList){
				user.wishList = {};
			}
			user.wishList[beer.id] = {
				"name": beer.name,
				"style": beer.style,
				"label": beer.labelUrl,
				"icon": beer.icon || "",
				"descript": beer.descript || "",
				"abv": beer.abv || "",
				"brewery": beer.brewery || "",
				"website": beer.website || ""
			}
			user.markModified('wishList');

		});
		dislikes.forEach(function(beer){
			if(!user.dislikes){
				user.dislikes = {};
			}
			user.dislikes[beer.id] = {
				"name": beer.name,
				"style": beer.style,
				"label": beer.labelUrl,
				"icon": beer.icon || "",
				"descript": beer.descript || "",
				"abv": beer.abv || "",
				"brewery": beer.brewery || "",
				"website": beer.website || ""
			}
			user.markModified('dislikes');
		});		
		user.save(function(err,user){
			if(err){
				console.log("Error saving wishlist and or dislikes");
			}
			console.log('updated wishlist and dislikes');
		});
		res.json({"SUCCESS": "updated wishlist and dislikes"});
	})
})

router.put('/wishlist', auth.checkUser, function(req,res){
	var username = req.body.username;
	var itemToDelete = req.body.wishlist[0];
	var addToDislikes = req.body.dislikes[0];

	db.User.findOne({username:username},function(err,user){
		if(err){
			console.log('err finding user');
			res.json({"error": err});
		}
		if(itemToDelete){
			var beerId = itemToDelete.id
			if(beerId in user.wishList){
				delete user.wishList[beerId];
				user.markModified('wishList');
			} else {
				console.log("not finding beerId in wishList");
			}
		}
		if(!user.dislikes){
			user.dislikes = {};
		}
		if(addToDislikes){
			user.dislikes[addToDislikes.id] = {
				"name": addToDislikes.name,
				"style": addToDislikes.style,
				"label": addToDislikes.labelUrl,
				"icon": addToDislikes.icon || "",
				"descript": addToDislikes.descript || "",
				"abv": addToDislikes.abv || "",
				"brewery": addToDislikes.brewery || "",
				"website": addToDislikes.website || ""
			}
			user.markModified('dislikes');
		}	
		user.save(function(err,user){
			if(err){
				console.log("Error saving wishlist and or dislikes");
			}
			console.log('updated wishlist and dislikes in PUT');
		});
		res.json({"SUCCESS": "updated wishlist and dislikes in PUT"});
	})
})

module.exports = router;