//
//  BeerView.swift
//  BeerMe
//
//  Created by Thomas Leupp on 5/3/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import Foundation
import UIKit
import MDCSwipeToChoose

class ChooseBeerView: MDCSwipeToChooseView {
    
    let ChooseBeerViewImageLabelWidth:CGFloat = 42.0;
    var beer: Beer!
    var informationView: UIView!
    var nameLabel: UILabel!
    
    init(frame: CGRect, beer: Beer, options: MDCSwipeToChooseViewOptions) {
        
        super.init(frame: frame, options: options)
        
        self.beer = beer
        
        if let image = self.beer.Label {
            self.imageView.image = image
        }
        
        self.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        UIViewAutoresizing.FlexibleBottomMargin
        
        self.imageView.contentMode = .ScaleAspectFit
        //self.imageView.contentMode = .ScaleAspectFill
        let x:CGFloat = 0.0
        let y:CGFloat = 0.0
        let w:CGFloat = 374.0
        let h:CGFloat = 374.0
        
        self.imageView.frame = CGRectMake(x,y,w,h)
        
        self.imageView.autoresizingMask = self.autoresizingMask
        constructInformationView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func constructInformationView() -> Void{
    /*    let bottomHeight:CGFloat = 60.0
        //let bottomHeight:CGFloat = 200.0
        let bottomFrame:CGRect = CGRectMake(0,
                                            (CGRectGetHeight(self.bounds) + bottomHeight),
                                            CGRectGetWidth(self.bounds),
                                            bottomHeight);
        self.informationView = UIView(frame:bottomFrame)
       // self.informationView.backgroundColor = UIColor.whiteColor()
       // self.informationView.clipsToBounds = true
        self.informationView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleTopMargin]
        self.addSubview(self.informationView)    */
        constructNameLabel()
    }
    
    func constructNameLabel() -> Void{
        let leftPadding:CGFloat = 0.0
        //let topPadding:CGFloat = 17.0
        let topPadding:CGFloat = 370.0
        //let topPadding:CGFloat = 30.0
//        let frame:CGRect = CGRectMake(leftPadding,
//                                      topPadding,floor(CGRectGetWidth(self.informationView.frame)/2),
//                                      CGRectGetHeight(self.informationView.frame) - topPadding)
        let w:CGFloat = 374.0
        let h:CGFloat = 70.0
        let frame:CGRect = CGRectMake(leftPadding,
                                      topPadding,w,
                                      h)

        self.nameLabel = UILabel(frame:frame)
        self.nameLabel.backgroundColor = UIColor.whiteColor()
        self.nameLabel.font = UIFont(name: "Avenir Next Condensed", size:25)
        self.nameLabel.text = "\(beer.Name)"
        self.nameLabel.textAlignment = .Center
       // self.informationView.addSubview(self.nameLabel)
        self.addSubview(self.nameLabel)
    }

}