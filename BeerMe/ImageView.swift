//
//  ImageView.swift
//  BeerMe
//
//  Created by Thomas Leupp on 5/3/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import Foundation
import UIKit

//class ImagelabelView: UIView{
//    var imageView: UIImageView!
//    var label: UILabel!
//    
//    override init(frame: CGRect){
//        super.init(frame: frame)
//        imageView = UIImageView()
//        label = UILabel()
//        
//        print("CGRectGetWidth(self.bounds)!!!!")
//        print(CGRectGetWidth(self.bounds))
//    }
//    
//    init(frame: CGRect, image: UIImage, text: String) {
//        super.init(frame: frame)
//        constructImageView(image)
//        constructLabel(text)
//        
//        print("CGRectGetWidth(self.bounds)!!!!")
//        print(CGRectGetWidth(self.bounds))
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)!
//    }
//    
//    func constructImageView(image:UIImage) -> Void{
//        let topPadding:CGFloat = 10.0
//        //let topPadding:CGFloat = 240.0
//        //let framex = CGRectMake(floor((CGRectGetWidth(self.bounds) - image.size.width)/2),
//        
//        print("CGRectGetWidth(self.bounds)!!!!")
//        print(CGRectGetWidth(self.bounds))
//        
//        let framex = CGRectMake(floor((CGRectGetWidth(self.bounds) - image.size.width)/2),
//                                topPadding,
//                                image.size.width,
//                                image.size.height)
//        imageView = UIImageView(frame: framex)
//        imageView.image = image
//        addSubview(self.imageView)
//    }
//    
//    func constructLabel(text:String) -> Void{
//        let height:CGFloat = 18.0
//        let frame2 = CGRectMake(0,
//                                CGRectGetMaxY(self.imageView.frame),
//                                CGRectGetWidth(self.bounds),
//                                height);
//        self.label = UILabel(frame: frame2)
//        label.text = text
//        addSubview(label)
//        
//        print("CGRectGetWidth(self.bounds)!!!!")
//        print(CGRectGetWidth(self.bounds))
//    }
//}
