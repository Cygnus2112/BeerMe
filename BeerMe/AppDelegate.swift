//
//  AppDelegate.swift
//  BeerMe
//
//  Created by Thomas Leupp on 4/30/16.
//  Copyright © 2016 Thomas Leupp. All rights reserved.
//

import UIKit
import Foundation
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
      NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
    NSUserDefaults.standardUserDefaults().removeObjectForKey("password")
//        NSUserDefaults.standardUserDefaults().setObject("zxzx", forKey: "username")
//        NSUserDefaults.standardUserDefaults().setObject("zxzx", forKey: "password")
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let user = NSUserDefaults.standardUserDefaults().objectForKey("username")
        
        print(user)
        
        if user != nil {
            let initViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController") as UIViewController
            self.window?.rootViewController = initViewController
        } else {
            let initViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as UIViewController
            self.window?.rootViewController = initViewController
        }
        return true
    }    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "MDCSwipeToChoose.SwiftLikedOrNope" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("BeerMe", withExtension: "momd")!
        
        print(modelURL)
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
}

