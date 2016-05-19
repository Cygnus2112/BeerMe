//
//  EmptyWishlistController.swift
//  BeerMe
//
//  Created by Thomas Leupp on 5/13/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import Foundation
import UIKit



class EmptyWishListViewController : UIViewController {
    
    
    let bgColor = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let bgColor = CAGradientLayer()
        bgColor.frame = self.view.bounds
        let color1 = UIColor(red:1.00, green:1.00, blue:0.80, alpha:1.0)
        let color2 = UIColor(red:1.00, green:0.80, blue:0.40, alpha:1.0)
        bgColor.colors = [color2.CGColor, color1.CGColor]
        view.layer.insertSublayer(bgColor, atIndex: 0)
        
        
        
    }

   


}