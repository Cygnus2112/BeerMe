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

// Code for Tinder-style swiping. Using MDCSwipeToChoose plugin.

class BeerSwipeController: UIViewController, MDCSwipeToChooseDelegate {
    let bgColor = CAGradientLayer()
    
    var style = ""
    var beers:[Beer] = []
    var wishList: [Beer] = []
    
    var wishListWorkaround : [AnyObject] = []
    var wishListBeerArrayWorkaround : [Beer] = []
    
    
    var wishListToAdd : [AnyObject] = []
    var dislikesToAdd : [AnyObject] = []
    
    let ChooseBeerButtonHorizontalPadding:CGFloat = 40.0
    let ChooseBeerButtonVerticalPadding:CGFloat = 35.0
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
        
        bgColor.frame = self.view.bounds
        // light gray background:
//        let color1 = UIColor(red:0.93, green:0.95, blue:0.93, alpha:1.0)
//        let color2 = UIColor(red:0.93, green:0.95, blue:0.93, alpha:1.0)
        
        // light gold background:
        let color1 = UIColor(red:1.00, green:1.00, blue:0.80, alpha:1.0)
        let color2 = UIColor(red:1.00, green:0.80, blue:0.40, alpha:1.0)
        
        bgColor.colors = [color2.CGColor, color1.CGColor]
        view.layer.insertSublayer(bgColor, atIndex: 0)
       
        self.setMyFrontCardView(self.popPersonViewWithFrame(frontCardViewFrame())!)
        self.view.addSubview(self.frontCardView)

        self.backCardView = self.popPersonViewWithFrame(backCardViewFrame())!
        
        self.backCardView.layer.borderColor = UIColor.blackColor().CGColor
        self.backCardView.layer.cornerRadius = 5.0
        self.backCardView.layer.masksToBounds = true
        self.backCardView.layer.borderWidth = 2
        
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
        
        let request = Alamofire.request(.POST, APIurls().wishlist, parameters: parameters, headers: headers, encoding: .JSON)
        
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

            self.backCardView.layer.borderColor = UIColor.blackColor().CGColor
            self.backCardView.layer.cornerRadius = 5.0
            self.backCardView.layer.masksToBounds = true
            self.backCardView.layer.borderWidth = 2
            
            self.view.insertSubview(self.backCardView, belowSubview: self.frontCardView)
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.backCardView.alpha = 1.0
                },completion:nil)
        }
    }
    func setMyFrontCardView(frontCardView:ChooseBeerView) -> Void {
        self.frontCardView = frontCardView
        self.frontCardView.layer.borderColor = UIColor.blackColor().CGColor
        self.frontCardView.layer.cornerRadius = 5.0
        self.frontCardView.layer.masksToBounds = true
        self.frontCardView.layer.borderWidth = 2
        
        self.currentBeer = frontCardView.beer
    }
    
    func popPersonViewWithFrame(frame:CGRect) -> ChooseBeerView?{
        if(self.beers.count == 0){
            return nil;
        }
        
        let options:MDCSwipeToChooseViewOptions = MDCSwipeToChooseViewOptions()
        options.delegate = self
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
            let request = Alamofire.request(.GET, APIurls().fetchbeers, parameters: parameters)
            
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
        let topPadding:CGFloat = 100.0
       
        // let bottomPadding:CGFloat = 200.0
        
        let w:CGFloat = 374.0
        let h:CGFloat = 440.0
        
        //return CGRectMake(horizontalPadding,topPadding,CGRectGetWidth(self.view.frame) - (horizontalPadding * 2), CGRectGetHeight(self.view.frame) - bottomPadding)
        return CGRectMake(horizontalPadding,topPadding,w,h)
    }
    func backCardViewFrame() ->CGRect{
        let frontFrame:CGRect = frontCardViewFrame()
        
        return CGRectMake(frontFrame.origin.x, frontFrame.origin.y /* + 10.0 */, CGRectGetWidth(frontFrame), CGRectGetHeight(frontFrame))
    }
    func constructNopeButton() -> Void{
        let button:UIButton =  UIButton(type: UIButtonType.System)
         let image:UIImage = UIImage(named:"ic_thumb_down_3x")!
        button.frame = CGRectMake(ChooseBeerButtonHorizontalPadding+30, CGRectGetMaxY(self.frontCardView.frame) + ChooseBeerButtonVerticalPadding, image.size.width+20, image.size.height+20)
        button.setImage(image, forState: UIControlState.Normal)
        button.tintColor = UIColor.redColor()
        
        button.backgroundColor = UIColor.whiteColor()
        
        button.layer.cornerRadius = 5
       // button.layer.borderWidth = 1
        button.layer.shadowColor = UIColor.grayColor().CGColor
        button.layer.shadowOffset = CGSizeMake(0, 0)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.5
        
        button.addTarget(self, action: #selector(BeerSwipeController.nopeFrontCardView), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func constructLikedButton() -> Void{
        let button:UIButton = UIButton(type: UIButtonType.System)
        let image:UIImage = UIImage(named:"ic_thumb_up_3x")!
     //   button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - (ChooseBeerButtonHorizontalPadding+2), CGRectGetMaxY(self.frontCardView.frame) + (ChooseBeerButtonVerticalPadding+1), image.size.width, image.size.height)
        button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - (ChooseBeerButtonHorizontalPadding + 50), CGRectGetMaxY(self.frontCardView.frame) + (ChooseBeerButtonVerticalPadding), image.size.width+20, image.size.height+20)
        button.setImage(image, forState:UIControlState.Normal)
        button.tintColor = UIColor(red:1.00, green:0.62, blue:0.00, alpha:1.0)
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 5
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.grayColor().CGColor
        button.layer.shadowColor = UIColor.grayColor().CGColor
        button.layer.shadowOffset = CGSizeMake(0, 0)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.5
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
        addedLabel.center = CGPointMake(210, 700)
        addedLabel.textAlignment = NSTextAlignment.Center
        addedLabel.text = "Added to Wish List!"
        addedLabel.textColor = UIColor.blueColor()
        addedLabel.backgroundColor = UIColor.whiteColor()
        addedLabel.layer.masksToBounds = true
        addedLabel.layer.cornerRadius = 5
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
        
        let request = Alamofire.request(.GET, APIurls().wishlist, parameters: parameters, headers: headers)
        
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
                            
                            print("json.count + self.wishListBeerArrayWorkaround.count")
                            print(json.count + self.wishListBeerArrayWorkaround.count)
                            print("self.wishlist.count")
                            print(self.wishList.count)
                            
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