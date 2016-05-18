//
//  BeerSwipeController.swift
//  BeerMe
//
//  Created by Thomas Leupp on 5/3/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import Foundation
import MDCSwipeToChoose
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

// Code for Tinder-style swiping. Using MDCSwipeToChoose CocoaPod.

class BeerSwipeController: UIViewController, MDCSwipeToChooseDelegate {
    var style = ""
    var beers:[Beer] = []
    var wishList: [Beer] = []
    
    var wishListWorkaround : [AnyObject] = []
    var wishListBeerArrayWorkaround : [Beer] = []
    
    
    var wishListToAdd : [AnyObject] = []
    var dislikesToAdd : [AnyObject] = []
    
    let ChooseBeerButtonHorizontalPadding:CGFloat = 40.0
    let ChooseBeerButtonVerticalPadding:CGFloat = 40.0
    var currentBeer:Beer!
    var frontCardView:ChooseBeerView!
    var backCardView:ChooseBeerView!
    let username = NSUserDefaults.standardUserDefaults().objectForKey("username")!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
       
        self.setMyFrontCardView(self.popPersonViewWithFrame(frontCardViewFrame())!)
        self.view.addSubview(self.frontCardView)

        self.backCardView = self.popPersonViewWithFrame(backCardViewFrame())!
        self.view.insertSubview(self.backCardView, belowSubview: self.frontCardView)
        
        constructNopeButton()
        constructLikedButton()
        
    }
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        
        let parameters = [
            "username": self.username,
            "wishlist": wishListToAdd as AnyObject,
            "dislikes": dislikesToAdd as AnyObject
        ]
        
        let headers = ["x-access-token" : String(NSUserDefaults.standardUserDefaults().objectForKey("token")!)]
        
        let queue = dispatch_queue_create("com.tomleupp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        
       // let request = Alamofire.request(.POST, "http://localhost:8080/wishlist", parameters: parameters, headers: headers, encoding: .JSON)
        let request = Alamofire.request(.POST, "http://beermeserver.yxuemvb8nv.us-west-2.elasticbeanstalk.com/wishlist", parameters: parameters, headers: headers, encoding: .JSON)
        
        request.response(
            queue: queue,
            responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
            completionHandler: { response in
                
                let json = JSON(response.result.value!)
                print(json)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                }
            }
        )
    }
    
    func suportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.Portrait
    }
    
    func viewDidCancelSwipe(view: UIView) -> Void{
        print("You couldn't decide on \(self.currentBeer.Name)");
    }
    
    func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void{
        if(wasChosenWithDirection == MDCSwipeDirection.Left){
            var beerToAdd: [String:String] = [:]
            
            beerToAdd["name"] = self.currentBeer.Name as String
            beerToAdd["labelUrl"] = self.currentBeer.LabelUrl as String
            beerToAdd["id"] = self.currentBeer.Id as String
            beerToAdd["style"] = self.currentBeer.Style as String
            
            self.dislikesToAdd.append(beerToAdd)
            
            print("You noped: \(self.currentBeer.Name)")
            
            if(self.beers.count == 0){
                print("No more beers! Do another GET req");
            }
            
        } else {
            var beerToAdd: [String:AnyObject] = [:]
            
            beerToAdd["name"] = self.currentBeer.Name as String
            beerToAdd["labelUrl"] = self.currentBeer.LabelUrl as String
            beerToAdd["id"] = self.currentBeer.Id as String
            beerToAdd["style"] = self.currentBeer.Style as String
            
            self.wishListToAdd.append(beerToAdd)
            
            beerToAdd["label"] = self.currentBeer.Label as UIImage
            self.wishListWorkaround.append(beerToAdd)
            
            
            showAdded()
            
            print("You liked: \(self.currentBeer.Name)")
            
        }
        
        if(self.backCardView != nil){
            self.setMyFrontCardView(self.backCardView)
        }
        
        backCardView = self.popPersonViewWithFrame(self.backCardViewFrame())

        if(backCardView != nil){
            self.backCardView.alpha = 0.0
            self.view.insertSubview(self.backCardView, belowSubview: self.frontCardView)
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.backCardView.alpha = 1.0
                },completion:nil)
        }
    }
    func setMyFrontCardView(frontCardView:ChooseBeerView) -> Void {
        self.frontCardView = frontCardView
        self.currentBeer = frontCardView.beer
    }
    
    func popPersonViewWithFrame(frame:CGRect) -> ChooseBeerView?{
        if(self.beers.count == 0){
            return nil;
        }
        
        let options:MDCSwipeToChooseViewOptions = MDCSwipeToChooseViewOptions()
        options.delegate = self
        //options.threshold = 160.0
        
        options.onPan = { state -> Void in
            if(self.backCardView != nil){
                let frame:CGRect = self.frontCardViewFrame()
                self.backCardView.frame = CGRectMake(frame.origin.x, frame.origin.y-(state.thresholdRatio * 10.0), CGRectGetWidth(frame), CGRectGetHeight(frame))
            }
        }
        
        let beerView:ChooseBeerView = ChooseBeerView(frame: frame, beer: self.beers[0], options: options)
       
        self.beers.removeAtIndex(0)
        
        if self.beers.count < 3 {
            let parameters = ["username": username, "style": self.style]
            
            let queue = dispatch_queue_create("com.tomleupp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
            
        //    let request = Alamofire.request(.GET, "http://localhost:8080/fetchbeers", parameters: parameters)
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
                                   
                                }
                            }
                        )
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        
                      
                    }
                }
            )
        }
        return beerView
        
    }
    func frontCardViewFrame() -> CGRect{
        let horizontalPadding:CGFloat = 20.0
        //let topPadding:CGFloat = 60.0
        let topPadding:CGFloat = 80.0
        // let bottomPadding:CGFloat = 200.0
        let bottomPadding:CGFloat = 300.0
        return CGRectMake(horizontalPadding,topPadding,CGRectGetWidth(self.view.frame) - (horizontalPadding * 2), CGRectGetHeight(self.view.frame) - bottomPadding)
    }
    func backCardViewFrame() ->CGRect{
        let frontFrame:CGRect = frontCardViewFrame()
        return CGRectMake(frontFrame.origin.x, frontFrame.origin.y + 10.0, CGRectGetWidth(frontFrame), CGRectGetHeight(frontFrame))
    }
    func constructNopeButton() -> Void{
        let button:UIButton =  UIButton(type: UIButtonType.System)
        let image:UIImage = UIImage(named:"No thanks-31")!
        button.frame = CGRectMake(ChooseBeerButtonHorizontalPadding, CGRectGetMaxY(self.frontCardView.frame) + ChooseBeerButtonVerticalPadding, image.size.width, image.size.height)
        button.setImage(image, forState: UIControlState.Normal)
       // button.tintColor = UIColor(red: 247.0/255.0, green: 91.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        button.addTarget(self, action: #selector(BeerSwipeController.nopeFrontCardView), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func constructLikedButton() -> Void{
        let button:UIButton = UIButton(type: UIButtonType.System)
        let image:UIImage = UIImage(named:"BeerMeLogo-small")!
        button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - (ChooseBeerButtonHorizontalPadding+2), CGRectGetMaxY(self.frontCardView.frame) + (ChooseBeerButtonVerticalPadding-2), image.size.width, image.size.height)
        button.setImage(image, forState:UIControlState.Normal)
        
        //button.tintColor = UIColor(red: 29.0/255.0, green: 245.0/255.0, blue: 106.0/255.0, alpha: 1.0)
        button.addTarget(self, action: #selector(BeerSwipeController.likeFrontCardView), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
        
    }
    func nopeFrontCardView() -> Void{
        self.frontCardView.mdc_swipe(MDCSwipeDirection.Left)
    }
    func likeFrontCardView() -> Void{
        self.frontCardView.mdc_swipe(MDCSwipeDirection.Right)
    }
    
    var addedLabel:UILabel!
    func showAdded() {
        addedLabel = UILabel(frame: CGRectMake(0, 0, 200, 30))
        addedLabel.center = CGPointMake(210, 650)
        addedLabel.textAlignment = NSTextAlignment.Center
        addedLabel.text = "Added to Wish List!"
        addedLabel.textColor = UIColor.blueColor()
        self.view.addSubview(addedLabel)
    
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(BeerSwipeController.dismissAdded), userInfo: nil, repeats: false)
    }
    
    func dismissAdded(){
        addedLabel.removeFromSuperview()
    }
    
    
    @IBAction func loadWishList(sender: AnyObject) {
        
        //temporary workaround for async issue(s)...
        
        for beer in self.wishListWorkaround as! [[String: AnyObject]] {
            let beerObj = Beer(name: beer["name"] as! String, labelUrl: beer["labelUrl"] as! String, label: beer["label"] as! UIImage, id: beer["id"] as! String, style: beer["style"] as! String)
            
            self.wishListBeerArrayWorkaround.append(beerObj)
        }
        

        // end temporary workaround
        
        
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
                //  temporary workaround
                
                for beerObj in self.wishListBeerArrayWorkaround{
                    self.wishList.append(beerObj)
                }
                
                // end temporary workaround
                
                guard let resp = response.result.value else {
                    print("No wishlist!")
                    self.dismissViewControllerAnimated(false){
                        self.performSegueWithIdentifier("SwipeToWishListSegue", sender: nil)
                    }
                    return
                }
              
                if resp.allKeys.count == 0 {
                    print("No wishlist!")
                    self.dismissViewControllerAnimated(false){
                        self.performSegueWithIdentifier("SwipeToWishListSegue", sender: nil)
                    }
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
                               if self.wishList.count == json.count + self.wishListBeerArrayWorkaround.count {
                                    
                                    self.dismissViewControllerAnimated(false){
                                        self.performSegueWithIdentifier("SwipeToWishListSegue", sender: nil)
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
        if (segue.identifier == "SwipeToWishListSegue") {
            if let nav = segue.destinationViewController as? UINavigationController {
                let dest = nav.topViewController as! FavoritesViewController
                dest.wishList = self.wishList
            }
        }
        
    }


}