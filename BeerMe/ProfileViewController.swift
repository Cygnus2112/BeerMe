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
import Material

class ProfileViewController : UIViewController {
    var wishList : [Beer] = []
    
    @IBAction func loadWishList2(sender: AnyObject) {
        seriouslyLoadWishList()
        
    }
    
    @IBAction func loadWishList(sender: UIButton) {
        seriouslyLoadWishList()
    }
    
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
        //   func toolBar(){
//        print("toolbar called")
//        // Title label.
//        let titleLabel: UILabel = UILabel()
//        titleLabel.text = "BeerMe!"
//        titleLabel.textAlignment = .Left
//        titleLabel.textColor = MaterialColor.white
//        
//        // Detail label.
//        //        let detailLabel: UILabel = UILabel()
//        //        detailLabel.text = "Build Beautiful Software"
//        //        detailLabel.textAlignment = .Left
//        //        detailLabel.textColor = MaterialColor.white
//        
//        let menuImage: UIImage? = MaterialIcon.menu
//        
//        // Menu button.
//        let menuButton: FlatButton = FlatButton()
//        menuButton.pulseColor = MaterialColor.white
//        //  menuButton.pulseScale = false
//        menuButton.tintColor = MaterialColor.white
//        menuButton.setImage(menuImage, forState: .Normal)
//        menuButton.setImage(menuImage, forState: .Highlighted)
//        
//        // Switch control.
//        let switchControl: MaterialSwitch = MaterialSwitch(state: .Off, style: .LightContent, size: .Small)
//        
//        // Search button.
//        let searchImage = MaterialIcon.search
//        let searchButton: FlatButton = FlatButton()
//        searchButton.pulseColor = MaterialColor.white
//        // searchButton.pulseScale = false
//        searchButton.tintColor = MaterialColor.white
//        searchButton.setImage(searchImage, forState: .Normal)
//        searchButton.setImage(searchImage, forState: .Highlighted)
//        
//        let toolbar: Toolbar = Toolbar()
//        toolbar.statusBarStyle = .LightContent
//        toolbar.backgroundColor = MaterialColor.blue.base
//        //  toolbar.titleLabel = titleLabel
//        // toolbar.detailLabel = detailLabel
//        toolbar.leftControls = [menuButton]
//        toolbar.rightControls = [switchControl, searchButton]
        
        
        
    }
    
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
