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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow()
        let rootView = ViewController()
        
        if let window = self.window {
            window.rootViewController = rootView
            window.backgroundColor = UIColor.whiteColor()
            window.makeKeyAndVisible()
        }
        
        return true
    }
}

