//
//  ViewController.swift
//  Fairfares
//
//  Created by Matthew Olson on 7/19/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locManager : CLLocationManager!
    @IBOutlet weak var uberSurge: UIButton!
    @IBOutlet weak var uberETA: UILabel!
    @IBOutlet weak var lyftSurge: UIButton!
    @IBOutlet weak var lyftETA: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let uberGradient: CAGradientLayer = CAGradientLayer()
    let lyftGradient: CAGradientLayer = CAGradientLayer()
    
    var uberSurgeDict: [String: Double] = [:]
    var lyftSurgeDict: [String: Double] = [:]
    
    var uberETADict: [String: Double] = [:]
    var lyftETADict: [String: Double] = [:]
    
    func displayUberSurge() {
        DispatchQueue.main.async {
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.setUberSurge(carType: "UberPool")
            } else if self.segmentedControl.selectedSegmentIndex == 1 {
                self.setUberSurge(carType: "UberX")
            } else if self.segmentedControl.selectedSegmentIndex == 2 {
                self.setUberSurge(carType: "UberXL")
            }
        }
    }
    
    func displayUberETA() {
        DispatchQueue.main.async {
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.setUberETA(carType: "UberPool")
            } else if self.segmentedControl.selectedSegmentIndex == 1 {
                self.setUberETA(carType: "UberX")
            } else if self.segmentedControl.selectedSegmentIndex == 2 {
                self.setUberETA(carType: "UberXL")
            }
        }
    }
    
    func displayLyftSurge () {
        DispatchQueue.main.async {
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.setLyftSurge(carType: "Shared")
            } else if self.segmentedControl.selectedSegmentIndex == 1 {
                self.setLyftSurge(carType: "Lyft")
            } else if self.segmentedControl.selectedSegmentIndex == 2 {
                self.setLyftSurge(carType: "Lyft XL")
            }
        }
    }
    
    func displayLyftETA () {
        DispatchQueue.main.async {
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.setLyftETA(carType: "Shared")
            } else if self.segmentedControl.selectedSegmentIndex == 1 {
                self.setLyftETA(carType: "Lyft")
            } else if self.segmentedControl.selectedSegmentIndex == 2 {
                self.setLyftETA(carType: "Lyft XL")
            }
        }
    }
    
    @IBAction func segmentChanged () {
        self.displayUberSurge()
        self.displayLyftSurge()
        self.displayUberETA()
        self.displayLyftETA()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidOpenFromBackground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startUpdatingLocation()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        uberGradient.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        uberGradient.locations = [0, 0.7, 0.7, 1.0]
        uberGradient.startPoint = CGPoint(x: 0.5, y: 0)
        uberGradient.endPoint = CGPoint(x: 0.5, y: 1)
        uberGradient.cornerRadius = uberSurge.layer.cornerRadius
        uberGradient.borderColor = UIColor.black.cgColor
        uberGradient.borderWidth = 5.0
        uberSurge.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        uberSurge.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        uberSurge.layer.shadowOpacity = 1.0
        uberSurge.layer.shadowRadius = 0.0
        uberSurge.layer.masksToBounds = false
        uberSurge.titleLabel?.minimumScaleFactor = 0.5
        uberSurge.titleLabel?.adjustsFontSizeToFitWidth = true
        
        let pinkColor = UIColor(red:1.00, green:0.00, blue:0.73, alpha:1.0).cgColor
        lyftGradient.colors = [pinkColor, pinkColor, UIColor.white.cgColor, UIColor.white.cgColor]
        lyftGradient.locations = [0, 0.7, 0.7, 1.0]
        lyftGradient.startPoint = CGPoint(x: 0.5, y: 0)
        lyftGradient.endPoint = CGPoint(x: 0.5, y: 1)
        lyftGradient.cornerRadius = lyftSurge.layer.cornerRadius
        lyftGradient.borderColor = pinkColor
        lyftGradient.borderWidth = 5.0
        lyftSurge.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        lyftSurge.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        lyftSurge.layer.shadowOpacity = 1.0
        lyftSurge.layer.shadowRadius = 0.0
        lyftSurge.layer.masksToBounds = false
        lyftSurge.titleLabel?.minimumScaleFactor = 0.5
        lyftSurge.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidLayoutSubviews() {
        uberGradient.frame = uberSurge.bounds
        uberSurge.layer.insertSublayer(uberGradient, at: 0)

        lyftGradient.frame = lyftSurge.bounds
        lyftSurge.layer.insertSublayer(lyftGradient, at: 0)
        
        scrollView.frame = UIScreen.main.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEvent(withCategory: "App", action: "Open", label: nil, value: nil).build() as [NSObject : AnyObject])
        GAI.sharedInstance().dispatch()
        
        locManager.startUpdatingLocation()
    }
    
    @objc func appDidOpenFromBackground() {
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEvent(withCategory: "App", action: "Reopen", label: nil, value: nil).build() as [NSObject : AnyObject])
        GAI.sharedInstance().dispatch()
        
        locManager.startUpdatingLocation()
    }
    
    @objc func refreshView(sender: UIRefreshControl) {
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEvent(withCategory: "App", action: "Refresh", label: nil, value: nil).build() as [NSObject : AnyObject])
        GAI.sharedInstance().dispatch()
        
        locManager.startUpdatingLocation()
        sender.endRefreshing()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.count > 0) {
            let currentLocation = locations[0]
            locManager.stopUpdatingLocation()
            
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            
            self.uberSurgeDict["TEST"] = 0.0
            self.lyftSurgeDict["TEST"] = 0.0
            
            self.uberETADict["TEST"] = 0.0
            self.lyftETADict["TEST"] = 0.0
            
            self.getUberSurges(lat: lat, lon: lon)
            self.getLyftSurges(lat: lat, lon: lon)
            
            self.getUberETAs(lat: lat, lon: lon)
            self.getLyftETAs(lat: lat, lon: lon)
        }
    }
    
    func getUberSurges(lat:CLLocationDegrees, lon:CLLocationDegrees) {
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
                    
                    if let mult = uberCar["surge_multiplier"] {
                        self.uberSurgeDict[carName] = mult as? Double
                    }
                }
                self.displayUberSurge()
            } catch {
                print(error1!)
            }
        }).resume()
    }
    
    func getUberETAs(lat:CLLocationDegrees, lon:CLLocationDegrees) {
        let url1 = NSURL(string: "https://api.uber.com/v1/estimates/time?start_latitude=" + String(lat) + "&start_longitude=" + String(lon))
        let request1 = NSMutableURLRequest(url: url1! as URL)
        request1.httpMethod = "GET"
        request1.setValue("Token kWHSMejyzdpLL7-OoNpSPQSbHgzFF1TuFxmEOrtO", forHTTPHeaderField: "Authorization")
        let session1 = URLSession.shared
        session1.dataTask(with: request1 as URLRequest, completionHandler: { (returnData1, response1, error1) -> Void in
            do {
                let json1 = try JSONSerialization.jsonObject(with: returnData1!, options: []) as! NSDictionary
                let uberCars = json1["times"] as? NSArray
                for uberCarTemp in uberCars! {
                    let uberCar = uberCarTemp as! NSDictionary
                    let carName = uberCar["display_name"] as! String
                    
                    if let eta = uberCar["estimate"] {
                        self.uberETADict[carName] = eta as? Double
                    }
                }
                self.displayUberETA()
            } catch {
                print(error1!)
            }
        }).resume()
    }
    
    func getLyftSurges(lat:CLLocationDegrees, lon:CLLocationDegrees) {
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
                                
                                if let mult = lyftCar["primetime_percentage"] {
                                    let lSurgeString = mult as! String
                                    let lSurge = lSurgeString.dropLast()
                                    let lSurgeFloat = 1+Double(lSurge)!/100
                                    self.lyftSurgeDict[carName] = lSurgeFloat
                                }
                            }
                            self.displayLyftSurge()
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
    
    func getLyftETAs(lat:CLLocationDegrees, lon:CLLocationDegrees) {
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
                    
                    let url3 = NSURL(string: "https://api.lyft.com/v1/eta?lat=" + String(lat) + "&lng=" + String(lon))
                    let request3 = NSMutableURLRequest(url: url3! as URL)
                    request3.httpMethod = "GET"
                    request3.setValue("bearer " + token, forHTTPHeaderField: "Authorization")
                    let session3 = URLSession.shared
                    session3.dataTask(with: request3 as URLRequest, completionHandler: { (returnData3, response3, error3) -> Void in
                        do {
                            let json = try JSONSerialization.jsonObject(with: returnData3!, options: JSONSerialization.ReadingOptions()) as! NSDictionary
                            let lyftCars = json["eta_estimates"] as! NSArray
                            for lyftCarTemp in lyftCars {
                                let lyftCar = lyftCarTemp as! NSDictionary
                                let carName = lyftCar["display_name"] as! String
                                
                                if let eta = lyftCar["eta_seconds"] {
                                    self.lyftETADict[carName] = eta as? Double
                                }
                            }
                            self.displayLyftETA()
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
    
    func setUberSurge(carType:String) {
        if let mult = self.uberSurgeDict[carType] {
            DispatchQueue.main.async {
                self.uberSurge.setTitle(String(format: "%.2f", mult) + "x", for: .normal)
                self.uberSurge.titleLabel?.minimumScaleFactor = 0.5
                self.uberSurge.titleLabel?.adjustsFontSizeToFitWidth = true
                self.uberSurge.setNeedsDisplay()
            }
        } else if let _ = self.uberSurgeDict["TEST"] {
            DispatchQueue.main.async {
                self.uberSurge.setTitle("?.??x", for: .normal)
                self.uberSurge.titleLabel?.minimumScaleFactor = 0.5
                self.uberSurge.titleLabel?.adjustsFontSizeToFitWidth = true
                self.uberSurge.setNeedsDisplay()
            }
        } else {
            locManager.startUpdatingLocation()
        }
    }
    
    func setUberETA(carType:String) {
        if let eta = self.uberETADict[carType] {
            DispatchQueue.main.async {
                if (eta/60).rounded() == 1.0 {
                    self.uberETA.text = String(format: "%.0f", (eta/60).rounded()) + " minute away"
                } else {
                    self.uberETA.text = String(format: "%.0f", (eta/60).rounded()) + " minutes away"
                }
                self.uberETA.setNeedsDisplay()
            }
        } else if let _ = self.uberETADict["TEST"] {
            DispatchQueue.main.async {
                self.uberETA.text = "? minutes away"
                self.uberETA.setNeedsDisplay()
            }
        } else {
            locManager.startUpdatingLocation()
        }
    }
    
    func setLyftSurge(carType:String) {
        if let mult = self.lyftSurgeDict[carType] {
            DispatchQueue.main.async {
                self.lyftSurge.setTitle(String(format: "%.2f", mult) + "x", for: .normal)
                self.lyftSurge.titleLabel?.minimumScaleFactor = 0.5
                self.lyftSurge.titleLabel?.adjustsFontSizeToFitWidth = true
                self.lyftSurge.setNeedsDisplay()
            }
        } else if let _ = self.lyftSurgeDict["TEST"] {
            DispatchQueue.main.async {
                self.lyftSurge.setTitle("?.??x", for: .normal)
                self.lyftSurge.titleLabel?.minimumScaleFactor = 0.5
                self.lyftSurge.titleLabel?.adjustsFontSizeToFitWidth = true
                self.lyftSurge.setNeedsDisplay()
            }
        } else {
            locManager.startUpdatingLocation()
        }
    }
    
    func setLyftETA(carType:String) {
        if let eta = self.lyftETADict[carType] {
            DispatchQueue.main.async {
                if (eta/60).rounded() == 1.0 {
                    self.lyftETA.text = String(format: "%.0f", (eta/60).rounded()) + " minute away"
                } else {
                    self.lyftETA.text = String(format: "%.0f", (eta/60).rounded()) + " minutes away"
                }
                self.lyftETA.setNeedsDisplay()
            }
        } else if let _ = self.lyftETADict["TEST"] {
            DispatchQueue.main.async {
                self.lyftETA.text = "? minutes away"
                self.lyftETA.setNeedsDisplay()
            }
        } else {
            locManager.startUpdatingLocation()
        }
    }
    
    @IBAction func openUber() {
        print("Open uber")
        
        let surgeString = "Uber:" + (uberSurge.titleLabel?.text!)! + "|Lyft:" + (lyftSurge.titleLabel?.text!)!
        print(surgeString)
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEvent(withCategory: "App", action: "Uber", label: surgeString, value: nil).build() as [NSObject : AnyObject])
        GAI.sharedInstance().dispatch()
        
        let uberUrl  = URL(string: "uber://app")!
        let uberStore = URL(string: "itms-apps://itunes.apple.com/us/app/uber/id368677368?mt=8")!
        UIApplication.shared.open(uberUrl, options: [:]) { (success) in
            if (!success) {
                UIApplication.shared.open(uberStore, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func openLyft() {
        print("Open Lyft")
        
        let surgeString = "Uber:" + (uberSurge.titleLabel?.text!)! + "|Lyft:" + (lyftSurge.titleLabel?.text!)!
        print(surgeString)
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEvent(withCategory: "App", action: "Lyft", label: surgeString, value: nil).build() as [NSObject : AnyObject])
        GAI.sharedInstance().dispatch()
        
        let lyftUrl  = URL(string: "lyft://app")!
        let lyftStore = URL(string: "itms-apps://itunes.apple.com/us/app/lyft-taxi-app-alternative/id529379082?mt=8")!
        UIApplication.shared.open(lyftUrl, options: [:]) { (success) in
            if (!success) {
                UIApplication.shared.open(lyftStore, options: [:], completionHandler: nil)
            }
        }
    }
}

