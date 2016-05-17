//
//  BeerStylesController.swift
//  BeerMe
//
//  Created by Thomas Leupp on 5/5/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class BeerStylesController: UIViewController {
    
    // Do the BreweryDB API call on the back-end. When user makes a choice, 
    // send a GET request with username and style choice
    // use username to get likes & dislikes and only send those that
    // dont appear in either history
    
    var beers : [Beer] = []
    var style = ""
    var wishList : [Beer] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.beers = [Beer]()
    }
    
    @IBAction func loadBeers(sender: UIButton) {
        self.style = sender.currentTitle!
        
        let loadingView = UIAlertController(title: nil, message: "Finding matches...", preferredStyle: .Alert)
        
        loadingView.view.tintColor = UIColor.blackColor()
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating();
        
        loadingView.view.addSubview(loadingIndicator)
        presentViewController(loadingView, animated: true, completion: nil)
        
        let parameters = ["username": NSUserDefaults.standardUserDefaults().objectForKey("username")!, "style": self.style]
        
        let queue = dispatch_queue_create("com.tomleupp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        
       // let request = Alamofire.request(.GET, "http://localhost:8080/fetchbeers", parameters: parameters)
        
        let request = Alamofire.request(.GET, "http://beermeserver.yxuemvb8nv.us-west-2.elasticbeanstalk.com/fetchbeers", parameters: parameters)
        
        request.response(
            queue: queue,
            responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
            completionHandler: { response in
                let json = JSON(response.result.value!)
                
                for (key,subJson):(String, JSON) in json {
                    
                    var label : UIImage!
                    let labelUrl = String(json[key]["label"])
                    
                    let queue2 = dispatch_queue_create("com.tomleupp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
                    
                    let request2 = Alamofire.request(.GET, labelUrl)
                        request2.response(
                            queue: queue2,
                            responseSerializer: Request.imageResponseSerializer(),
                            completionHandler: { response in
                                
                                label = response.result.value!
                                
                                let beer = Beer(name: String(json[key]["name"]), labelUrl: labelUrl, label: label, id: key, style: String(json[key]["style"]))
                                
                                self.beers.append(beer)
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    if self.beers.count == json.count {
                                        
                                        self.dismissViewControllerAnimated(false){
                                            self.performSegueWithIdentifier("BeerSwipeSegue", sender: nil)
                                        }
                                        
                                    }
                                }
                            }
                        )
                    
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    
                }
            }
        )
    }
    
    @IBAction func loadWishList(sender: AnyObject) {
        seriouslyLoadWishList()
    }
    
    func seriouslyLoadWishList(){
        let loadingView = UIAlertController(title: nil, message: "Fetching Wish List...", preferredStyle: .Alert)
        
        loadingView.view.tintColor = UIColor.blackColor()
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating();
        
        loadingView.view.addSubview(loadingIndicator)
        presentViewController(loadingView, animated: true, completion: nil)
        
 
        let username = NSUserDefaults.standardUserDefaults().objectForKey("username")!
        let parameters = ["username": username]
        let headers = ["x-access-token" : String(NSUserDefaults.standardUserDefaults().objectForKey("token")!)]
        let queue = dispatch_queue_create("com.tomleupp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        
        //let request = Alamofire.request(.GET, "http://localhost:8080/wishlist", parameters: parameters, headers: headers)
        
        let request = Alamofire.request(.GET, "http://beermeserver.yxuemvb8nv.us-west-2.elasticbeanstalk.com/wishlist", parameters: parameters, headers: headers)
        
        request.response(
            queue: queue,
            responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
            completionHandler: { response in
                
                guard let resp = response.result.value else {
                    print("No wishlist!")
                    self.performSegueWithIdentifier("StylesToWishlistSegue", sender: nil)
                    return
                }
                
                let json = JSON(resp)
                
                for (key,subJson):(String, JSON) in json {
                    var label : UIImage!
                    let labelUrl = String(json[key]["label"])
                    let queue2 = dispatch_queue_create("com.tomleupp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
                    
                    let request2 = Alamofire.request(.GET, labelUrl)
                    
                    request2.response(
                        queue: queue2,
                        responseSerializer: Request.imageResponseSerializer(),
                        completionHandler: { response in
                            label = response.result.value!
                            
                            let beer = Beer(name: String(json[key]["name"]), labelUrl: labelUrl, label: label, id: key, style: String(json[key]["style"]))
                            
                            self.wishList.append(beer)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                if self.wishList.count == json.count {
                                    
                                    self.dismissViewControllerAnimated(false){
                                        self.performSegueWithIdentifier("StylesToWishlistSegue", sender: nil)
                                    }
  
                                }
                            }
                        }
                    )
                }
                dispatch_async(dispatch_get_main_queue()) {
                    
                }
            }
        )
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       if (segue.identifier == "BeerSwipeSegue") {
            if let dest = segue.destinationViewController as? BeerSwipeController {
                dest.style = self.style
                dest.beers = self.beers
            }
        }
        if (segue.identifier == "StylesToWishlistSegue") {
            if let nav = segue.destinationViewController as? UINavigationController {
                let dest = nav.topViewController as! FavoritesViewController
                dest.wishList = self.wishList
            }
        }
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}