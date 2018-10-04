//
//  CacheManager.swift
//  ParticleFoundation
//
//  Created by Rocco Del Priore on 10/3/18.
//  Copyright © 2018 Rocco Del Priore. All rights reserved.
//

import Foundation

class CacheManager {
    static let sharedInstance = CacheManager()
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func fileURL(url: URL, baseURL: URL) -> URL {
        //Create Directory Name
        var filename = baseURL
        for component in url.pathComponents {
            if component != "/" {
                filename = filename.appendingPathComponent(component)
            }
        }
        
        //Create Directory
        do {
            try FileManager.default.createDirectory(at: filename, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: ", filename)
        }
        
        //Append Filename
        if let query = url.query {
            filename = filename.appendingPathComponent(query.components(separatedBy: CharacterSet(charactersIn: "/:?%*|\"<>")).joined())
        }
        else {
            filename = filename.appendingPathComponent("default")
        }
        filename = filename.appendingPathExtension("json")
        
        return filename
    }
    
    public func getCachedResponse(url: URL, success: @escaping (Dictionary<String, Any>) -> Void, failure: @escaping (Error?) -> Void?) {
        let filename = self.fileURL(url: url, baseURL: Bundle.main.resourceURL!)
        do {
            let data = try Data(contentsOf: filename, options: .mappedIfSafe)
            if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? Dictionary<String, Any> {
                success(jsonResult)
            }
            else {
                failure(nil)
            }
        } catch {
            failure(error)
        }
    }
    
    public func cacheResponse(response: Data, url: URL) {
        if let contents = String(data: response, encoding: String.Encoding.utf8) {
            let filename = self.fileURL(url: url, baseURL: getDocumentsDirectory())
            
            //Write to File
            do {
                try contents.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                print("CacheManger wrote to file: ", filename.absoluteString)
            } catch {
                print("Failed to write to file: ", error)
            }
        }
    }
}
