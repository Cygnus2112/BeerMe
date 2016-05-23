//
//  SingleFavoriteController.swift
//  BeerMe
//
//  Created by Thomas Leupp on 5/2/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON


class BeerDetailViewController : UIViewController, UINavigationControllerDelegate {
    
    let bgColor = CAGradientLayer()
    
    let username = NSUserDefaults.standardUserDefaults().objectForKey("username")!
    var beerName = ""
    var style = ""
    var label : UIImage?
    var isInWishList = ""
    var labelUrl = ""
    var id = ""
    
    var currentBeer:Beer!
    //var wishList : [Beer] = []
    var wishList = BeerArray().array
    var presentingSegue = ""
    var wishListToRemove : [AnyObject] = []
    var dislikesToAdd : [AnyObject] = []
    
    var beerObject : [String:String] = [:]
    
    
    @IBOutlet weak var beerLabel: UIImageView!
    @IBOutlet weak var beerNameLabel: UILabel!
    @IBOutlet weak var beerStyleLabel: UILabel!
    
    @IBOutlet weak var wishListButton: UIButton!
    @IBOutlet weak var shoppingCart: UIButton!
    @IBOutlet weak var wishListLabel: UILabel!
    
    @IBAction func toggleWishList(sender: AnyObject) {
        if self.isInWishList == "true" {
            self.wishList = self.wishList.filter { $0 != self.currentBeer }
            let emptyHeart:UIImage = UIImage(named:"ic_favorite_border_3x")!
            let tintedHeart = emptyHeart.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            wishListButton.tintColor = UIColor(red:1.00, green:0.62, blue:0.00, alpha:1.0)
            wishListButton.setImage(tintedHeart, forState: UIControlState.Normal)
            
            self.dislikesToAdd = [beerObject]
            self.wishListToRemove = [beerObject]
            self.wishListLabel.text = "Add to Wish List"
            self.isInWishList = "false"
        } else {
            let filledHeart:UIImage = UIImage(named:"ic_favorite_filled_3x")!
            let tintedFilled = filledHeart.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            wishListButton.tintColor = UIColor(red:1.00, green:0.62, blue:0.00, alpha:1.0)
            wishListButton.setImage(tintedFilled, forState: UIControlState.Normal)
            
            self.wishList.append(self.currentBeer)
            self.wishListToRemove = []
            self.dislikesToAdd = []
            self.wishListLabel.text = "Remove from Wish List"
            self.isInWishList = "true"
        }
    }
    
    //TODO:  present map of places to buy, etc.
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? FavoritesViewController {
            controller.wishList = self.wishList
            controller.tableView(UITableView(), numberOfRowsInSection:0)
            controller.viewWillAppear(animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgColor.frame = self.view.bounds
        let color1 = UIColor(red:1.00, green:1.00, blue:0.80, alpha:1.0)
        let color2 = UIColor(red:1.00, green:0.80, blue:0.40, alpha:1.0)
        bgColor.colors = [color2.CGColor, color1.CGColor]
        view.layer.insertSublayer(bgColor, atIndex: 0)
        
        navigationController?.delegate = self
        
        self.beerLabel.image = label
        self.beerLabel.layer.borderColor = UIColor.blackColor().CGColor
        self.beerLabel.layer.cornerRadius = 5.0
        self.beerLabel.layer.masksToBounds = true
        self.beerLabel.layer.borderWidth = 2
        
        self.beerNameLabel.text = beerName
        self.beerStyleLabel.text = style
        
        self.beerObject["name"] = self.beerName
        self.beerObject["style"] = self.style
        self.beerObject["id"] = self.id
        self.beerObject["labelUrl"] = self.labelUrl
        
        if self.presentingSegue == "FavoriteSegue" {
            let image:UIImage = UIImage(named:"ic_favorite_filled_3x")!
            let tintedImage = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            
            wishListButton.setImage(tintedImage, forState: UIControlState.Normal)
            self.isInWishList = "true"
            self.wishListLabel.text = "Remove from Wish List"
            
            wishListButton.tintColor = UIColor(red:1.00, green:0.62, blue:0.00, alpha:1.0)
            
           // wishListButton.backgroundColor = UIColor(red:0.93, green:0.95, blue:0.93, alpha:1.0)
            wishListButton.backgroundColor = UIColor.whiteColor()
            wishListButton.layer.cornerRadius = 5
            wishListButton.layer.shadowColor = UIColor.grayColor().CGColor
            wishListButton.layer.shadowOffset = CGSizeMake(0, 0)
            wishListButton.layer.shadowRadius = 5
            wishListButton.layer.shadowOpacity = 0.5
        } else {
            let image:UIImage = UIImage(named:"ic_favorite_border_3x")!
            let tintedImage = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            
            wishListButton.setImage(tintedImage, forState: UIControlState.Normal)
            self.wishListLabel.text = "Add to Wish List"
            self.isInWishList = "false"
            
            wishListButton.tintColor = UIColor(red:1.00, green:0.62, blue:0.00, alpha:1.0)
            
//            wishListButton.backgroundColor = UIColor(red:0.93, green:0.95, blue:0.93, alpha:1.0)
            wishListButton.backgroundColor = UIColor.whiteColor()
            wishListButton.layer.cornerRadius = 5
            wishListButton.layer.shadowColor = UIColor.grayColor().CGColor
            wishListButton.layer.shadowOffset = CGSizeMake(0, 0)
            wishListButton.layer.shadowRadius = 5
            wishListButton.layer.shadowOpacity = 0.5
        }
        
        let image2:UIImage = UIImage(named:"ic_shopping_cart_3x")!
        
        let tintedImage2 = image2.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

        shoppingCart.setImage(tintedImage2, forState: .Normal)
      //  shoppingCart.tintColor = UIColor(red:0.40, green:0.20, blue:0.00, alpha:1.0)
        shoppingCart.tintColor = UIColor(red:1.00, green:0.62, blue:0.00, alpha:1.0)
        shoppingCart.backgroundColor = UIColor.whiteColor()
        //shoppingCart.backgroundColor = UIColor(red:0.93, green:0.95, blue:0.93, alpha:1.0)
        shoppingCart.layer.cornerRadius = 5
        
        //        button.layer.borderWidth = 1
        //        button.layer.borderColor = UIColor.grayColor().CGColor
        
        shoppingCart.layer.shadowColor = UIColor.grayColor().CGColor
        shoppingCart.layer.shadowOffset = CGSizeMake(0, 0)
        shoppingCart.layer.shadowRadius = 5
        shoppingCart.layer.shadowOpacity = 0.5
    }
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        
        if self.wishListToRemove.isEmpty == false {
            let parameters = [
                "username": self.username,
                "wishlist": self.wishListToRemove as AnyObject,
                "dislikes": self.dislikesToAdd as AnyObject
            ]
        
            let headers = ["x-access-token" : String(NSUserDefaults.standardUserDefaults().objectForKey("token")!)]
            let queue = dispatch_queue_create("com.tomleupp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        
           //     let request = Alamofire.request(.PUT, "http://localhost:8080/wishlist", parameters: parameters, headers: headers, encoding: .JSON)
            let request = Alamofire.request(.PUT, APIurls().wishlist, parameters: parameters, headers: headers, encoding: .JSON)
        
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
    }
}
