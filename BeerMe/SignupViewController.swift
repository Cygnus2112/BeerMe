//
//  SignupViewController.swift
//  BeerMe
//
//  Created by Thomas Leupp on 5/1/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class SignupViewController : UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var errorMessage: UILabel!  // TODO: form validation for signup
    
    @IBAction func signupButton(sender: UIButton) {
        // TODO: instantiate new User model instance instead of this...
        
        let parameters = [
            "username": username.text!,
            "password": password.text!,
            "email": email.text!
        ]
        print(parameters)
        
        let queue = dispatch_queue_create("com.tomleupp.manager-response-queue", DISPATCH_QUEUE_CONCURRENT)
        
//        let request = Alamofire.request(.POST, "http://localhost:8080/signup", parameters: parameters,encoding: .JSON)
        let request = Alamofire.request(.POST, "http://beermeserver.yxuemvb8nv.us-west-2.elasticbeanstalk.com/signup", parameters: parameters,encoding: .JSON)
        
        
        
        request.response(
            queue: queue,
            responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
            completionHandler: { response in
                
                let token = JSON(response.result.value!)
                print("token (hopefully):")
                print(token)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    NSUserDefaults.standardUserDefaults().setObject(self.username.text!, forKey: "username")
                    NSUserDefaults.standardUserDefaults().setObject(self.password.text!, forKey: "password")
                    NSUserDefaults.standardUserDefaults().setObject(String(token["token"]), forKey: "token")
                    
                    self.performSegueWithIdentifier("SignupToProfileSegue", sender: nil)
                }
            }
        )
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