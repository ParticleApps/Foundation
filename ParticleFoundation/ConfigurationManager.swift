//
//  ConfigurationManager.swift
//  ParticleFoundation
//
//  Created by Rocco Del Priore on 10/4/18.
//  Copyright © 2018 Rocco Del Priore. All rights reserved.
//

import Foundation

class ConfigurationManager {
    static let sharedInstance = ConfigurationManager()
    public let payload: Dictionary<String, Any>
    private(set) var loadFromCache: Bool = false
    private(set) var saveToCache: Bool = false
    
    init() {
        guard
            let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
            let configuration = NSDictionary(contentsOfFile: path) as? Dictionary<String, Any> else {
                print("Exiting due to a broken configuration file!")
                self.payload = Dictionary<String, Any>()
                assert(false)
                return
        }
        
        self.payload = configuration
        self.loadFromCache = configuration["loadFromCache"] as? Bool ?? false
        self.saveToCache = configuration["saveToCache"] as? Bool ?? false
    }
}
