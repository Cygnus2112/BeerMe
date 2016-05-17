//
//  BeerModel.swift
//  BeerMe
//
//  Created by Thomas Leupp on 5/3/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import Foundation
import UIKit

class Beer: NSObject {
    
    let Name: NSString
    let Id: NSString
    let LabelUrl: NSString
    let Label: UIImage!
    let Style: NSString
    
    override var description: String {
        return "Name: \(Name), \n ID: \(Id), \n LabelUrl: \(LabelUrl), \n Label: \(Label), \n Style: \(Style) \n"
    }
    
    init(name: NSString?, labelUrl: NSString, label: UIImage?, id: NSString?, style: NSString?) {
        self.Name = name ?? ""
        self.LabelUrl = labelUrl ?? ""
        self.Label = label
        self.Id = id ?? ""
        self.Style = style ?? ""
    }
}

class BeerArray {
    var array: [Beer] = []
}


