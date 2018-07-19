//
//  ViewController.swift
//  Fairfares
//
//  Created by Matthew Olson on 7/19/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import CoreLocation
import Intents

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locManager : CLLocationManager!
    var uberSurge : UILabel!
    var lyftSurge : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        let scrollView = UIScrollView.init(frame: self.view.frame)
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        let bounds = UIScreen.main.bounds
        let buttonWidth = bounds.width - 20
        var buttonHeight = 0.4*bounds.height
        if bounds.height == 812 || bounds.height == 2436 { // iPhoneX TODO
            buttonHeight = bounds.height - 500
        }
        
        let logoView = UIImageView(frame: CGRect(x: (bounds.width-buttonWidth)/2, y: 0, width: bounds.width, height: 0.1*bounds.height))
        logoView.image = UIImage(named: "Logo.png")
        logoView.contentMode = .scaleAspectFit
        scrollView.addSubview(logoView)
        
        let uberButton = UIButton(frame: CGRect(x:(bounds.width-buttonWidth)/2,y:0.125*bounds.height,width:buttonWidth,height:buttonHeight))
        uberButton.backgroundColor = UIColor.black
        uberButton.layer.cornerRadius = 15
        uberButton.clipsToBounds = true
        uberButton.addTarget(self, action: #selector(openUber), for: .touchUpInside)
        
        let uberLogo = UIImageView(frame: CGRect(x:buttonWidth/6, y:0.2*buttonHeight, width:4/6*buttonWidth, height:0.3*buttonHeight))
        uberLogo.image = UIImage(named: "uber.png")
        uberButton.addSubview(uberLogo)
        
        uberSurge = UILabel(frame: CGRect(x:buttonWidth/6, y:0.5*buttonHeight, width:4/6*buttonWidth, height:0.3*buttonHeight))
        uberSurge.text = "?.??x"
        uberSurge.textColor = UIColor.white
        uberSurge.textAlignment = NSTextAlignment.center;
        uberSurge.font = uberSurge.font.withSize(bounds.height/10)
        uberButton.addSubview(uberSurge)
        
        scrollView.addSubview(uberButton)
        
        let lyftButton = UIButton(frame: CGRect(x:(bounds.width-buttonWidth)/2,y:0.55*bounds.height,width:buttonWidth,height:buttonHeight))
        lyftButton.backgroundColor = UIColor.magenta
        lyftButton.layer.cornerRadius = 15
        lyftButton.clipsToBounds = true
        lyftButton.addTarget(self, action: #selector(openLyft), for: .touchUpInside)
        
        let lyftLogo = UIImageView(frame: CGRect(x:0.25*buttonWidth, y:0.2*buttonHeight, width:0.5*buttonWidth, height:0.3*buttonHeight))
        lyftLogo.image = UIImage(named: "lyft.png")
        lyftButton.addSubview(lyftLogo)
        
        lyftSurge = UILabel(frame: CGRect(x:buttonWidth/6, y:0.5*buttonHeight, width:4/6*buttonWidth, height:0.3*buttonHeight))
        lyftSurge.text = "?.??x"
        lyftSurge.textColor = UIColor.white
        lyftSurge.textAlignment = NSTextAlignment.center
        lyftSurge.font = lyftSurge.font.withSize(bounds.height/10)
        lyftButton.addSubview(lyftSurge)
        
        scrollView.addSubview(lyftButton)
        
        locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startUpdatingLocation()
        
        INPreferences.requestSiriAuthorization { status in
            if status == .authorized {
                print("Hey, Siri!")
            } else {
                print("Nay, Siri!")
            }
        }
        
        self.view.addSubview(scrollView)
    }
    
    @objc func refreshView(sender: UIRefreshControl) {
        locManager.startUpdatingLocation()
        sender.endRefreshing()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.count > 0) {
            let currentLocation = locations[0]
            locManager.stopUpdatingLocation()
            
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            
            let url1 = NSURL(string: "https://api.uber.com/v1/estimates/price?start_latitude=" + String(lat) + "&start_longitude=" + String(lon) + "&end_latitude=" + String(lat) + "&end_longitude=" + String(lon))
            let request1 = NSMutableURLRequest(url: url1! as URL)
            request1.httpMethod = "GET"
            request1.setValue("Token kWHSMejyzdpLL7-OoNpSPQSbHgzFF1TuFxmEOrtO", forHTTPHeaderField: "Authorization")
            let session1 = URLSession.shared
            session1.dataTask(with: request1 as URLRequest, completionHandler: { (returnData1, response1, error1) -> Void in
                do {
                    let json1 = try JSONSerialization.jsonObject(with: returnData1!, options: []) as! NSDictionary
                    let uberCars = json1["prices"] as? NSArray
                    for uberCarTemp in uberCars! {
                        let uberCar = uberCarTemp as! NSDictionary
                        let carName = uberCar["display_name"] as! String
                        if carName == "UberX" || carName == "uberX" {
                            let uSurge = uberCar["surge_multiplier"] as! Double
                            DispatchQueue.main.async {
                                self.uberSurge.text = String(format: "%.2f", uSurge) + "x"
                                self.uberSurge.setNeedsDisplay()
                            }
                        }
                    }
                } catch {
                    print(error1!)
                }
            }).resume()
            
            do {
                let url2 = NSURL(string: "https://api.lyft.com/oauth/token")
                let request2 = NSMutableURLRequest(url: url2! as URL)
                let json2 = [ "grant_type":"client_credentials" , "scope": "public" ]
                let jsonData2 = try JSONSerialization.data(withJSONObject: json2, options: .prettyPrinted)
                
                request2.httpMethod = "POST"
                request2.httpBody = jsonData2
                request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let authorization = "7_DB9J4yrmiq:L4HrhTTa2Pempal8xvh-HhtoKpWEEsVQ".data(using:String.Encoding.utf8)?.base64EncodedString(options:NSData.Base64EncodingOptions(rawValue: 0))
                request2.setValue("Basic " + authorization!, forHTTPHeaderField: "Authorization")
                
                let session2 = URLSession.shared
                session2.dataTask(with: request2 as URLRequest as URLRequest, completionHandler: { (returnData2, response2, error2) -> Void in
                    do {
                        let json = try JSONSerialization.jsonObject(with: returnData2!, options: JSONSerialization.ReadingOptions()) as! NSDictionary
                        let token = json["access_token"] as! String
                        
                        let url3 = NSURL(string: "https://api.lyft.com/v1/cost?start_lat=" + String(lat) + "&start_lng=" + String(lon))
                        let request3 = NSMutableURLRequest(url: url3! as URL)
                        request3.httpMethod = "GET"
                        request3.setValue("bearer " + token, forHTTPHeaderField: "Authorization")
                        let session3 = URLSession.shared
                        session3.dataTask(with: request3 as URLRequest, completionHandler: { (returnData3, response3, error3) -> Void in
                            do {
                                let json = try JSONSerialization.jsonObject(with: returnData3!, options: JSONSerialization.ReadingOptions()) as! NSDictionary
                                let lyftCars = json["cost_estimates"] as! NSArray
                                for lyftCarTemp in lyftCars {
                                    let lyftCar = lyftCarTemp as! NSDictionary
                                    let carName = lyftCar["display_name"] as! String
                                    if carName == "Lyft" {
                                        let lSurgeString = lyftCar["primetime_percentage"] as! String
                                        let lSurge = lSurgeString.dropLast()
                                        let lSurgeFloat = Float(lSurge)!/100
                                        DispatchQueue.main.async {
                                            self.lyftSurge.text = String(format: "%.2f", 1+lSurgeFloat) + "x"
                                            self.lyftSurge.setNeedsDisplay()
                                        }
                                    }
                                }
                            } catch {
                                print(error3!)
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
    
    @objc func openUber() {
        print("Open uber")
        let uberUrl  = URL(string: "uber://app")!
        let uberStore = URL(string: "itms-apps://itunes.apple.com/us/app/uber/id368677368?mt=8")!
        UIApplication.shared.open(uberUrl, options: [:]) { (success) in
            if (!success) {
                UIApplication.shared.open(uberStore, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func openLyft() {
        print("Open Lyft")
        let lyftUrl  = URL(string: "lyft://app")!
        let lyftStore = URL(string: "itms-apps://itunes.apple.com/us/app/lyft-taxi-app-alternative/id529379082?mt=8")!
        UIApplication.shared.open(lyftUrl, options: [:]) { (success) in
            if (!success) {
                UIApplication.shared.open(lyftStore, options: [:], completionHandler: nil)
            }
        }
    }
}

