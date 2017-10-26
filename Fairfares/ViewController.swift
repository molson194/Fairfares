//
//  ViewController.swift
//  Fairfares
//
//  Created by Matthew Olson on 7/19/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import CoreLocation
import iAd

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locManager : CLLocationManager!
    var uberSurge : UILabel!
    var lyftSurge : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = UIScreen.mainScreen().bounds
        let diameter = (bounds.height-20)/2 - 10
        
        let uberButton = UIButton(frame: CGRectMake((bounds.width-diameter)/2,20,diameter,diameter))
        uberButton.backgroundColor = UIColor.blackColor()
        uberButton.layer.cornerRadius = diameter/2
        uberButton.clipsToBounds = true
        uberButton.addTarget(self, action: #selector(openUber), forControlEvents: UIControlEvents.TouchUpInside)
        
        let uberLogo = UIImageView(frame: CGRectMake(diameter/6,diameter/5,4/6*diameter,diameter/4))
        uberLogo.image = UIImage(named: "uber.png")
        uberButton.addSubview(uberLogo)
        
        uberSurge = UILabel(frame: CGRectMake(diameter/6, diameter/2, 4/6*diameter, diameter/4))
        uberSurge.text = "?.??x"
        uberSurge.textColor = UIColor.whiteColor()
        uberSurge.textAlignment = NSTextAlignment.Center;
        uberSurge.font = uberSurge.font.fontWithSize(diameter/5)
        uberButton.addSubview(uberSurge)
        
        self.view.addSubview(uberButton)
        
        let lyftButton = UIButton(frame: CGRectMake((bounds.width-diameter)/2,25+diameter,diameter,diameter))
        lyftButton.backgroundColor = UIColor.magentaColor()
        lyftButton.layer.cornerRadius = diameter/2
        lyftButton.clipsToBounds = true
        lyftButton.addTarget(self, action: #selector(openLyft), forControlEvents: UIControlEvents.TouchUpInside)
        
        let lyftLogo = UIImageView(frame: CGRectMake(diameter/5,diameter/6,0.6*diameter+10,diameter/3))
        lyftLogo.image = UIImage(named: "lyft.png")
        lyftButton.addSubview(lyftLogo)
        
        lyftSurge = UILabel(frame: CGRectMake(diameter/6, diameter/2, 4/6*diameter, diameter/4))
        lyftSurge.text = "?.??x"
        lyftSurge.textColor = UIColor.whiteColor()
        lyftSurge.textAlignment = NSTextAlignment.Center;
        lyftSurge.font = lyftSurge.font.fontWithSize(diameter/5)
        lyftButton.addSubview(lyftSurge)
        
        self.view.addSubview(lyftButton)
        
        locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startUpdatingLocation()

    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.count > 0) {
            let currentLocation = locations[0]
            locManager.stopUpdatingLocation()
            
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            
            let url1 = NSURL(string: "https://api.uber.com/v1/estimates/price?start_latitude=" + String(lat) + "&start_longitude=" + String(lon) + "&end_latitude=" + String(lat) + "&end_longitude=" + String(lon))
            let request1 = NSMutableURLRequest(URL: url1!)
            request1.HTTPMethod = "GET"
            request1.setValue("Token UBER_TOKEN", forHTTPHeaderField: "Authorization")
            let session1 = NSURLSession.sharedSession()
            session1.dataTaskWithRequest(request1, completionHandler: { (returnData1, response1, error1) -> Void in
                do {
                    let json1 = try NSJSONSerialization.JSONObjectWithData(returnData1!, options: NSJSONReadingOptions())
                    let uberCars = json1["prices"] as! NSArray
                    for uberCar in uberCars {
                        let carName = uberCar["display_name"] as! String
                        if carName == "uberX" {
                            dispatch_async(dispatch_get_main_queue(), {
                                let uSurge = uberCar["surge_multiplier"] as! Float
                                self.uberSurge.text = String(format: "%.2f", uSurge) + "x"
                                self.uberSurge.setNeedsDisplay()
                            })
                        }
                    }
                } catch {
                    print(error1)
                }
            }).resume()
            
            do {
                let url2 = NSURL(string: "https://api.lyft.com/oauth/token")
                let request2 = NSMutableURLRequest(URL: url2!)
                let json2 = [ "grant_type":"client_credentials" , "scope": "public" ]
                let jsonData2 = try NSJSONSerialization.dataWithJSONObject(json2, options: .PrettyPrinted)
                
                request2.HTTPMethod = "POST"
                request2.HTTPBody = jsonData2
                request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let authorization = "LYFT_TOKEN".dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                request2.setValue("Basic " + authorization, forHTTPHeaderField: "Authorization")
                
                let session2 = NSURLSession.sharedSession()
                session2.dataTaskWithRequest(request2, completionHandler: { (returnData2, response2, error2) -> Void in
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(returnData2!, options: NSJSONReadingOptions())
                        let token = json["access_token"] as! String
                        
                        let url3 = NSURL(string: "https://api.lyft.com/v1/cost?start_lat=" + String(lat) + "&start_lng=" + String(lon))
                        let request3 = NSMutableURLRequest(URL: url3!)
                        request3.HTTPMethod = "GET"
                        request3.setValue("bearer " + token, forHTTPHeaderField: "Authorization")
                        let session3 = NSURLSession.sharedSession()
                        session3.dataTaskWithRequest(request3, completionHandler: { (returnData3, response3, error3) -> Void in
                            do {
                                let json = try NSJSONSerialization.JSONObjectWithData(returnData3!, options: NSJSONReadingOptions())
                                let lyftCars = json["cost_estimates"] as! NSArray
                                for lyftCar in lyftCars {
                                    let carName = lyftCar["display_name"] as! String
                                    if carName == "Lyft" {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            let lSurgeString = lyftCar["primetime_percentage"] as! String
                                            let lSurge = lSurgeString.substringToIndex(lSurgeString.endIndex.predecessor())
                                            let lSurgeFloat = Float(lSurge)!/100
                                            self.lyftSurge.text = String(format: "%.2f", 1+lSurgeFloat) + "x"
                                            self.lyftSurge.setNeedsDisplay()
                                        })
                                    }
                                }
                            } catch {
                                print(error3)
                            }
                        }).resume()
                        
                        
                    } catch {
                        print(error)
                    }
                }).resume()
            } catch {
                
            }
        }
    }
    
    func openUber() {
        print("Open uber")
        let uberUrl  = NSURL(string: "uber://app");
        let uberStore = NSURL(string: "itms-apps://itunes.apple.com/us/app/uber/id368677368?mt=8")
        if UIApplication.sharedApplication().canOpenURL(uberUrl!) == true {
            UIApplication.sharedApplication().openURL(uberUrl!)
        } else {
            UIApplication.sharedApplication().openURL(uberStore!)
        }
    }
    
    func openLyft() {
        print("Open Lyft")
        let lyftUrl  = NSURL(string: "lyft://app");
        let lyftStore = NSURL(string: "itms-apps://itunes.apple.com/us/app/lyft-taxi-app-alternative/id529379082?mt=8")
        if UIApplication.sharedApplication().canOpenURL(lyftUrl!) == true {
            UIApplication.sharedApplication().openURL(lyftUrl!)
        } else {
            UIApplication.sharedApplication().openURL(lyftStore!)
        }
    }
}

