//
//  TodayViewController.swift
//  SurgeWidget
//
//  Created by Matthew Olson on 7/21/18.
//  Copyright © 2018 Molson. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
    
    var locManager : CLLocationManager!
    @IBOutlet weak var uberSurge: UIButton!
    @IBOutlet weak var lyftSurge: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        // Every time user goes to widgets, this runs
        locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
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
                                self.uberSurge.setTitle(String(format: "%.2f", uSurge) + "x", for: .normal)
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
                                            self.lyftSurge.setTitle(String(format: "%.2f", 1+lSurgeFloat) + "x", for: .normal)
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
    
    @IBAction func openUber() {
        print("Open uber")
        let uberUrl  = URL(string: "uber://app")!
        let uberStore = URL(string: "itms-apps://itunes.apple.com/us/app/uber/id368677368?mt=8")!
        
        self.extensionContext?.open(uberUrl, completionHandler: { (success) in
            if (!success) {
                self.extensionContext?.open(uberStore, completionHandler: nil)
            }
        })
    }
    
    @IBAction func openLyft() {
        print("Open Lyft")
        let lyftUrl  = URL(string: "lyft://app")!
        let lyftStore = URL(string: "itms-apps://itunes.apple.com/us/app/lyft-taxi-app-alternative/id529379082?mt=8")!
        
        self.extensionContext?.open(lyftUrl, completionHandler: { (success) in
            if (!success) {
                self.extensionContext?.open(lyftStore, completionHandler: nil)
            }
        })
        
    }
    
}
