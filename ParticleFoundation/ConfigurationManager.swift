//
//  ConfigurationManager.swift
//  ParticleFoundation
//
//  Created by Rocco Del Priore on 10/4/18.
//  Copyright © 2018 Rocco Del Priore. All rights reserved.
//

import Foundation

open class ConfigurationManager {
    static let sharedInstance = ConfigurationManager()
    public let payload: Dictionary<String, Any>
    private(set) var loadFromCache: Bool = false
    private(set) var saveToCache: Bool = false
    
    public enum Keys: String {
        case loadFromCache = "loadFromCache"
        case saveToCache = "saveToCache"
    }
    
    public init() {
        guard
            let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
            let configuration = NSDictionary(contentsOfFile: path) as? Dictionary<String, Any> else {
                print("ConfigurationManager: Missing configuration file.")
                self.payload = Dictionary<String, Any>()
                return
        }
        
        self.payload = configuration
        self.loadFromCache = configuration[ConfigurationManager.Keys.loadFromCache.rawValue] as? Bool ?? false
        self.saveToCache = configuration[ConfigurationManager.Keys.saveToCache.rawValue] as? Bool ?? false
    }
}
