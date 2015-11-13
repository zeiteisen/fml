//
//  AppDelegate.swift
//  fml
//
//  Created by Hanno Bruns on 17.10.15.
//  Copyright © 2015 zeiteisens. All rights reserved.
// A8eZrWg0pcx1Qcmsnmhv5oVWbr1WlvqWg1oa8Oji
// TODOs
/*
 Für das iPad anpassen
*/

import UIKit
import Parse
import LaunchKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        LaunchKit.launchWithToken("eUjQ6vHyPCz6s1BbVibXGMb7zmjLETRpHAKSv0fpTpGz")
        Parse.enableLocalDatastore()
        Parse.setApplicationId(Constants.parseApplicationId, clientKey: Constants.parseClientId)
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        PFUser.enableAutomaticUser()
        let user = PFUser.currentUser()
        if user?.objectId == nil {
            user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    LaunchKit.sharedInstance().setUserIdentifier(user?.objectId, email: user?.email, name: user?.objectForKey("author") as? String)
                }
            })
        } else {
            LaunchKit.sharedInstance().setUserIdentifier(user?.objectId, email: user?.email, name: user?.objectForKey("author") as? String)
            if (LKAppUserIsSuper()) {
                user?.setObject(true, forKey: "superuser")
                user?.saveEventually()
            } else {
                user?.setObject(false, forKey: "superuser")
                user?.saveEventually()
            }
        }
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
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
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current Installation and save it to Parse
        print("devicetoken: \(deviceToken)")
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
}

