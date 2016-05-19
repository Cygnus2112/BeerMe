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
    let bgColor = CAGradientLayer()
    let bgColor2 = CAGradientLayer()
    var wishList = BeerArray().array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let bgColor = CAGradientLayer()
        bgColor.frame = self.view.bounds
        let color1 = UIColor(red:1.00, green:1.00, blue:0.80, alpha:1.0)
        let color2 = UIColor(red:1.00, green:0.80, blue:0.40, alpha:1.0)
        bgColor.colors = [color2.CGColor, color1.CGColor]
        view.layer.insertSublayer(bgColor, atIndex: 0)
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
      //  cell.backgroundColor = UIColor.cyanColor()
//        bgColor2.frame = cell.bounds
//        let color1 = UIColor(red:1.00, green:1.00, blue:0.80, alpha:1.0)
//        let color2 = UIColor(red:1.00, green:0.80, blue:0.40, alpha:1.0)
//        bgColor2.colors = [color1.CGColor, color2.CGColor]
      
       // cell.layer.insertSublayer(bgColor2, atIndex: 0)
        
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.cornerRadius = 2.0
                cell.layer.masksToBounds = true
                cell.layer.borderWidth = 1
        
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
