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
        
        self.imageView.autoresizingMask = self.autoresizingMask
        constructInformationView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func constructInformationView() -> Void{
        let bottomHeight:CGFloat = 60.0
        let bottomFrame:CGRect = CGRectMake(0,
                                            CGRectGetHeight(self.bounds) - bottomHeight,
                                            CGRectGetWidth(self.bounds),
                                            bottomHeight);
        self.informationView = UIView(frame:bottomFrame)
        self.informationView.backgroundColor = UIColor.whiteColor()
        self.informationView.clipsToBounds = true
        self.informationView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleTopMargin]
        self.addSubview(self.informationView)
        constructNameLabel()
    }
    
    func constructNameLabel() -> Void{
        let leftPadding:CGFloat = 12.0
        let topPadding:CGFloat = 17.0
        let frame:CGRect = CGRectMake(leftPadding,
                                      topPadding,
                                      floor(CGRectGetWidth(self.informationView.frame)/2),
                                      CGRectGetHeight(self.informationView.frame) - topPadding)
        self.nameLabel = UILabel(frame:frame)
        self.nameLabel.font = UIFont(name: "Avenir Next Condensed", size:25)
        self.nameLabel.text = "\(beer.Name)"
        self.informationView .addSubview(self.nameLabel)
    }
    
    func buildImageLabelViewLeftOf(x:CGFloat, image:UIImage) -> ImagelabelView{
        let frame:CGRect = CGRect(x:x-ChooseBeerViewImageLabelWidth, y: 0,
                                  width: ChooseBeerViewImageLabelWidth,
                                  height: CGRectGetHeight(self.informationView.bounds))
        
        let view:ImagelabelView = ImagelabelView(frame:frame, image:image, text:beer.Name as String)
        
        
        view.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        return view
    }
}