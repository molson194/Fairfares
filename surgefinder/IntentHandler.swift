//
//  IntentHandler.swift
//  surgefinder
//
//  Created by Matthew Olson on 7/17/18.
//  Copyright © 2018 Molson. All rights reserved.
//

import Intents

class IntentHandler: INExtension, INListRideOptionsIntentHandling {
    override func handler(for intent: INIntent) -> Any? {
        return self
    }
    
    func handle(intent: INListRideOptionsIntent, completion: @escaping (INListRideOptionsIntentResponse) -> Void) {
        let response = INListRideOptionsIntentResponse(code: .success, userActivity: nil)
        
        let pickupDate = Date(timeIntervalSinceNow: 240)
        let rideOption = INRideOption(name: "Batmobile LINE", estimatedPickupDate: pickupDate)
        
        rideOption.priceRange = INPriceRange(minimumPrice: 42.0, currencyCode: "USD")
        rideOption.disclaimerMessage = "This ride is cray cray."
        
        response.rideOptions = [rideOption]
        
        completion(response)
    }
    
    
}
