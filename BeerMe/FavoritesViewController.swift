//
//  FavoritesViewController.swift
//  BeerMe
//
//  Created by Thomas Leupp on 5/2/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class FavoritesViewController : UITableViewController {
    var wishList : [Beer] = []
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("wishList.count")
        print(wishList.count)
        return wishList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Basic")!
        
        let beer = wishList[indexPath.row]
        cell.textLabel?.text = beer.Name as String
        
        cell.textLabel?.font = UIFont(name: "Avenir Next Condensed", size: 20)
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "FavoriteSegue") {
            let beer = wishList[tableView.indexPathForSelectedRow!.row]
            let name = beer.Name
            let label = beer.Label
            let style = beer.Style
            
            
            if let dest = segue.destinationViewController as? SingleFavoriteController {
                dest.title = name as String
                dest.label = label
                dest.style = style as String
                
            }
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.wishList.isEmpty {
//            let backgroundImage = UIImage(named:"beer-pint-350")
//            let imageView = UIImageView(image: backgroundImage)
//            self.tableView.backgroundView = imageView
            
            // temporary workaround
            self.performSegueWithIdentifier("EmptyWishlistSegue", sender: nil)
            
        }
        
       
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
