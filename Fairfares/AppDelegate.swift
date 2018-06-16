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
    let rootView = ViewController()
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window = UIWindow()
        
        if let window = self.window {
            window.rootViewController = rootView
            window.backgroundColor = UIColor.white
            window.makeKeyAndVisible()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        rootView.locManager.startUpdatingLocation()
    }
}

