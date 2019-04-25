//
//  BaseNetworkManager.swift
//  ParticleFoundation
//
//  Created by Rocco Del Priore on 10/4/18.
//  Copyright © 2018 Rocco Del Priore. All rights reserved.
//

import Foundation
import CoreData

open class BaseDataManager {
    open var persistentContainer: NSPersistentContainer = {
        let containerName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            else {
            }
        })
        return container
    }()
    
    //MARK: Initializers
    public init() {
        //Do nothing
    }
    
    //MARK: Network Requests
    public func makeRequestForString(request: URLRequest, success: @escaping (String) -> Void, failure: @escaping (Error?) -> Void?) {
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { (data, response, error) in
            if let responseData = data {
                if ConfigurationManager.sharedInstance.saveToCache {
                    CacheManager.sharedInstance.cacheResponse(response: data!, url: request.url!)
                }
                if let response = String(data: responseData, encoding: String.Encoding.utf8) {
                    success(response)
                }
                else {
                    failure(error)
                }
            }
            else {
                failure(error)
            }
        }
        task.resume()
    }
    open func makeRequestForJSONDictionary(request: URLRequest, success: @escaping (Dictionary<String, Any>) -> Void, failure: @escaping (Error?) -> Void?) {
        if ConfigurationManager.sharedInstance.loadFromCache {
            if let url = request.url {
                CacheManager.sharedInstance.getCachedDictionaryResponse(url: url, success: success, failure: failure)
            }
        }
        else {
            let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { (data, response, error) in
                if let _ = data {
                    do {
                        if ConfigurationManager.sharedInstance.saveToCache {
                            CacheManager.sharedInstance.cacheResponse(response: data!, url: request.url!)
                        }
                        if let json  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as? Dictionary<String, Any> {
                            success(json)
                        }
                        else {
                            failure(error)
                        }
                    } catch let error as NSError {
                        failure(error)
                    }
                }
                else {
                    failure(error)
                }
            }
            task.resume()
        }
    }
    open func makeRequestForJSONArray(request: URLRequest, success: @escaping (Array<Any>) -> Void, failure: @escaping (Error?) -> Void?) {
        if ConfigurationManager.sharedInstance.loadFromCache {
            if let url = request.url {
                CacheManager.sharedInstance.getCachedArrayResponse(url: url, success: success, failure: failure)
            }
        }
        else {
            let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { (data, response, error) in
                if let _ = data {
                    do {
                        if ConfigurationManager.sharedInstance.saveToCache {
                            CacheManager.sharedInstance.cacheResponse(response: data!, url: request.url!)
                        }
                        if let json  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as? Array<Any> {
                            success(json)
                        }
                        else {
                            failure(error)
                        }
                    } catch let error as NSError {
                        failure(error)
                    }
                }
                else {
                    failure(error)
                }
            }
            task.resume()
        }
    }
    
    //MARK: Helpers
    open func requestForURL(url: URL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 200)
        return request
    }
    
    //MARK: Core Data
    open func deleteManagedObject(object: NSManagedObject, success: @escaping () -> Void, failure: @escaping (Error?) -> Void?) {
        self.persistentContainer.viewContext.delete(object)
        self.saveCurrentContext(success: success, failure: failure)
    }
    open func saveCurrentContext(success: @escaping () -> Void, failure: @escaping (Error?) -> Void?) {
        do {
            try self.persistentContainer.viewContext.save()
        } catch {
            failure(error)
        }
    }
}
