//
//  AppDelegate.swift
//  Fairfares
//
//  Created by Matthew Olson on 7/19/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let rootView = ViewController()
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window = UIWindow()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-APP_ID")
        
        if let window = self.window {
            window.rootViewController = rootView
            window.backgroundColor = UIColor.white
            window.makeKeyAndVisible()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        rootView.locManager.startUpdatingLocation()
    }
}

