//
//  ViewController.swift
//  BeerMe
//
//  Created by Thomas Leupp on 4/30/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var wishList:[Beer] = []
    
    @IBAction func loginButton(sender: UIButton) {
        if username.text!.isEmpty {
            errorMessage.text = "Please enter a username."
        } else if password.text!.isEmpty {
            errorMessage.text = "Please enter your password"
        } else if username.text! != (NSUserDefaults.standardUserDefaults().objectForKey("username") as? String) {
            errorMessage.text = "Username incorrect"        
        } else if password.text! != (NSUserDefaults.standardUserDefaults().objectForKey("password") as? String) {
            errorMessage.text = "Password incorrect"
        } else {
            
            let parameters = [
                "username": username.text!,
                "password": password.text!
            ]
            
            let queue = dispatch_queue_create("com.tomleupp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
            
//            let request = Alamofire.request(.POST, "http://localhost:8080/login", parameters: parameters,encoding: .JSON)
            let request = Alamofire.request(.POST, "http://beermeserver.yxuemvb8nv.us-west-2.elasticbeanstalk.com/login", parameters: parameters,encoding: .JSON)
            
            request.response(
                queue: queue,
                responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
                completionHandler: { response in
                    
                    let token = JSON(response.result.value!)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        NSUserDefaults.standardUserDefaults().setObject(self.username.text!, forKey: "username")
                        NSUserDefaults.standardUserDefaults().setObject(self.password.text!, forKey: "password")
                        NSUserDefaults.standardUserDefaults().setObject(String(token["token"]), forKey: "token")
                        
                        print("login successful")
                        
                        self.performSegueWithIdentifier("LoginToStylesSegue", sender: nil)
                    }
                }
            )
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

