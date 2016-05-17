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
//    var wishList : [Beer] = []
    
    var wishList = BeerArray().array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if self.wishList.isEmpty {
//            
//            // temporary workaround
//            self.performSegueWithIdentifier("EmptyWishlistSegue", sender: nil)
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.tableView.numberOfRowsInSection(0)
        
        if self.wishList.isEmpty {
            
            // temporary workaround
            self.performSegueWithIdentifier("EmptyWishlistSegue", sender: nil)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
            let labelUrl = beer.LabelUrl
            let style = beer.Style
            let id = beer.Id
            
            
            if let dest = segue.destinationViewController as? BeerDetailViewController {
                dest.beerName = name as String
                dest.label = label
                dest.labelUrl = labelUrl as String
                dest.id = id as String
                dest.style = style as String
                dest.presentingSegue = "FavoriteSegue"
                
                dest.currentBeer = beer
                dest.wishList = self.wishList
                
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
