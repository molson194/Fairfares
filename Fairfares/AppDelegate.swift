//
//  AppDelegate.swift
//  Fairfares
//
//  Created by Matthew Olson on 7/19/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        guard let gai = GAI.sharedInstance() else {
            return false
        }
        gai.tracker(withTrackingId: "UA-105754354-2")
        gai.trackUncaughtExceptions = true
        
        return true
    }
}

