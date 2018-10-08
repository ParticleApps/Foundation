//
//  LocationManager.swift
//  ParticleFoundation
//
//  Created by Rocco Del Priore on 9/14/18.
//  Copyright © 2018 Rocco Del Priore. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let locationDidChangeNotification = NSNotification.Name(rawValue: "locationsDidChange")
    static let sharedInstance = LocationManager()
    private let manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    var isAvailable: Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            return true
        }
        return false
    }
    var location: CLLocation? {
        didSet {
            NotificationCenter.default.post(name: LocationManager.locationDidChangeNotification, object: nil)
        }
    }
    
    //MARK: Initializers
    override init() {
        super.init()
        manager.delegate = self
    }
    
    //MARK: Actions
    func startUpdatingLocation() {
        if self.isAvailable {
            manager.startUpdatingLocation()
        }
        else {
            manager.requestWhenInUseAuthorization()
        }
    }
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.startUpdatingLocation()
        }
        else {
            self.stopUpdatingLocation()
        }
    }
}
