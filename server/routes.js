var express = require('express');
var router = express.Router();
var db = require('./database');
var request = require('request');
var Promise = require('bluebird');
var bcrypt = require('bcrypt');
var fs = require('fs')
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

var downloadAllBeers = function() {
    var now = Date.now();
    var beerArray = []
    var page = 1;
    var url = "http://api.brewerydb.com/v2/beers?key="+breweryKey+"&p="+page+"&availableId=1&hasLabels=y&withBreweries=y";
    var allBeers = fs.createWriteStream('./server/beersOutput.js')
	
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
    		return page < 105;
		}, function() {    			
			return new Promise(function(resolve, reject) {    
            url = "http://api.brewerydb.com/v2/beers?key="+'336ad89cea47e683efa68ee5c51f7449'+"&p="+(page++)+"&availableId=1&hasLabels=y&withBreweries=y"; 		
        		request.get(url, function(err, response, body) { 
        			if(err){
            			console.log("error in downloadAllBeers: ", err);
        			}
        			console.log("---------------------");       
                    beerArray.push(body); 
        			resolve();      
				});
    		});
		}).then(function() {
            allBeers.write(JSON.stringify(beerArray))
			allBeers.end();

            console.log('Done. Time to complete BreweryDBdownload: ');
            console.log((Date.now() - now)/1000)
		});  
}

downloadAllBeers();

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

	if(username){
	  db.User.findOne({username:username},function(err,user){
		if(err){
			console.log('error finding user in DB');
			res.send(err);
		}
		wishList = user.wishList || {};
		dislikes = user.dislikes || {};
	  })
	}

	if(style === "Pilsner") {
		style = "Pilsener";
	}

	// do a while search with random setting and keep checking if we don't find beers w/that style

	// var foundBeers = 0;
	// var beersFetched = {};

	function shuffle (array) {
  		var i = 0
    		, j = 0
    		, temp = null

 		 for (i = array.length - 1; i > 0; i -= 1) {
   			j = Math.floor(Math.random() * (i + 1))
   			 	temp = array[i]
    			array[i] = array[j]
    			array[j] = temp
  		}
	}

	var cb = (err, data) => {
		var beers = [];
		var now = Date.now();
		var a = JSON.parse(data)
		//var a = JSON.parse(data)
		for(var i = 0; i < a.length; i++) {
			var b = JSON.parse(a[i])
			var data = b['data'];
			for(var j = 0; j < data.length; j++) {
				if(data[j]['style']){
					if(data[j].style.name.includes(style)){
						beers.push(data[j]);
					}
				}	
			}	
		}
		shuffle(beers);
		var count = 0;
		var chosen = {};
		var numsUsed = {};
		console.log('beers.length');
		console.log(beers.length);
		while(count < 20){
			var num = (Math.floor(Math.random() * (beers.length - 1)))
			if(!(num in numsUsed) && !(beers[num]['id'] in wishList) && !(beers[num]['id'] in dislikes)) {
				chosen[beers[num]['id']] = {
					'name': beers[num]['name'], 
					"descript": beers[num].description,
					"label": beers[num].labels.medium,
					"style": beers[num].style.name,
					"icon": beers[num].labels.icon,
					"descript": beers[num].description,
					"abv": beers[num].abv,
					"brewery": beers[num].breweries[0].name,
					"website": beers[num].breweries[0].website
				};
				count++;
			}
			numsUsed[num] = num
		}
		console.log(chosen);
		res.json(chosen);
		console.log('Done. Time to complete data parsing: ');
        console.log((Date.now() - now)/1000)
	}

	fs.readFile('./server/beersOutput.js', 'utf8', cb) 
})

// router.get('/fetchbeers', function(req,res){
// 	var username = req.query.username;
// 	var style;
// 	if(!req.query.style) {
// 		style = "Ale";
// 		console.log('req.query.style undefined!!!');
// 	} else {
// 		style = req.query.style;
// 	}

// 	var wishList = {};
// 	var dislikes = {};

// 	if(username){
// 	  db.User.findOne({username:username},function(err,user){
// 		if(err){
// 			console.log('error finding user in DB');
// 			res.send(err);
// 		}
// 		wishList = user.wishList || {};
// 		dislikes = user.dislikes || {};
// 	  })
// 	}
// 	// ------------------
// 	var url = "http://api.brewerydb.com/v2/beers?key="+breweryKey+"&availableId=1&hasLabels=y&order=random&randomCount=10&withBreweries=y";
	
// 	if(style === "Pilsner") {
// 		style = "Pilsener";
// 	}

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
//         		request.get(url, function(err, response, body) { 
//         			if(err){
//             			console.log("error in fetchbeers: ", err);
//         			}
//         			console.log("---------------------");       

//        // TODO separate out into sep file:
//         			var data = JSON.parse(body);

//         			if(data.errorMessage) {
//         				console.error("BreweryDB error: ", data.errorMessage);
//         				res.json(data);
//         				return;
//         			} else if(data.data[0].style){
//         				data.data.forEach(function(beer){
//         					if(beer.style){
//         						if(beer.style.name.includes(style) &&
//         							!(beer.id in wishList) &&
//         							!(beer.id in dislikes)){
// 									foundBeers++;
// 									beersFetched[beer.id] = {
// 										"name": beer.name,
// 										"label": beer.labels.medium,
// 										"style": beer.style.name,
// 										"icon": beer.labels.icon,
// 										"descript": beer.description,
// 										"abv": beer.abv,
// 										"brewery": beer.breweries[0].name,
// 										"website": beer.breweries[0].website
// 									}
// 								}
// 							}
//         				})
//     				} 

//         			console.log("---------------------");   
//         			if(foundBeers >= 2){
//         				console.log(beersFetched);
//         				res.json(beersFetched); 
//         			}
//         			resolve();      
// 				});
//     		});
// 		}).then(function() {
//     		console.log("Done");
// 		});  
// })


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