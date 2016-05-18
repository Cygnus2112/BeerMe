//
//  ProfileViewController.swift
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

// NOTE: This view controller (ProfileViewController) is no longer in use. I'm keeping it around in case I want to implement some version of it later.


class ProfileViewController : UIViewController {
    var wishList : [Beer] = []
    
    func seriouslyLoadWishList(){
        let username = NSUserDefaults.standardUserDefaults().objectForKey("username")!
        let parameters = ["username": username]
        let headers = ["x-access-token" : String(NSUserDefaults.standardUserDefaults().objectForKey("token")!)]
        let queue = dispatch_queue_create("com.tomleupp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        
      //  let request = Alamofire.request(.GET, "http://localhost:8080/wishlist", parameters: parameters, headers: headers)
        
        let request = Alamofire.request(.GET, "http://beermeserver.yxuemvb8nv.us-west-2.elasticbeanstalk.com/wishlist", parameters: parameters, headers: headers)
        
        request.response(
            queue: queue,
            responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
            completionHandler: { response in
                
                guard let resp = response.result.value else {
                    print("No wishlist!")
                    self.performSegueWithIdentifier("FavoritesSegue", sender: nil)
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
                                    self.performSegueWithIdentifier("FavoritesSegue", sender: nil)
                                }
                            }
                        }
                    )
                }
                dispatch_async(dispatch_get_main_queue()) {
                    print("Am I back on the main thread333: \(NSThread.isMainThread())")
                }
            }
        )
    }
            
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "FavoritesSegue") {
            if let nav = segue.destinationViewController as? UINavigationController {
                let dest = nav.topViewController as! FavoritesViewController
                dest.wishList = self.wishList
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
