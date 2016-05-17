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
            wishListButton.setImage(emptyHeart, forState: UIControlState.Normal)
            self.dislikesToAdd = [beerObject]
            self.wishListToRemove = [beerObject]
            self.wishListLabel.text = "Add to Wish List"
            self.isInWishList = "false"
        } else {
            let filledHeart:UIImage = UIImage(named:"ic_favorite_filled_3x")!
            wishListButton.setImage(filledHeart, forState: UIControlState.Normal)
            
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
        
        navigationController?.delegate = self
        
        self.beerLabel.image = label
        self.beerNameLabel.text = beerName
        self.beerStyleLabel.text = style
        
        self.beerObject["name"] = self.beerName
        self.beerObject["style"] = self.style
        self.beerObject["id"] = self.id
        self.beerObject["labelUrl"] = self.labelUrl
        
        if self.presentingSegue == "FavoriteSegue" {
            let image:UIImage = UIImage(named:"ic_favorite_filled_3x")!
            wishListButton.setImage(image, forState: UIControlState.Normal)
            self.isInWishList = "true"
            self.wishListLabel.text = "Remove from Wish List"
        } else {
            let image:UIImage = UIImage(named:"ic_favorite_border_3x")!
            wishListButton.setImage(image, forState: UIControlState.Normal)
            self.wishListLabel.text = "Add to Wish List"
            self.isInWishList = "false"
        }
        
        let image2:UIImage = UIImage(named:"ic_shopping_cart_3x")!
        shoppingCart.setImage(image2, forState: UIControlState.Normal)
        
        
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
        let request = Alamofire.request(.PUT, "http://beermeserver.yxuemvb8nv.us-west-2.elasticbeanstalk.com/wishlist", parameters: parameters, headers: headers, encoding: .JSON)
        
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

//    override func willMoveToParentViewController(parent: UIViewController?) {
//       if parent == nil {
//            print("parent")
//            print(self.parentViewController)
//            print("Back button pressed")
//       }
//    }
    
}
