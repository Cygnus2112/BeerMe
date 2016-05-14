//
//  UserModel.swift
//  BeerMe
//
//  Created by Thomas Leupp on 5/8/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import Foundation

class User: NSObject {
    
    let Username: NSString
    let Password: NSString
    let Email: NSString
    
    override var description: String {
        return "Username: \(Username), \n Password: \(Password), \n Email: \(Email) \n"
    }
    
    init(username: NSString?, password: NSString?, email: NSString?) {
        self.Username = username ?? ""
        self.Password = password ?? ""
        self.Email = email ?? ""
    }
}