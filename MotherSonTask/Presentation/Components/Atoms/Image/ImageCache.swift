//
//  ImageCache.swift
//  MotherSonTask
//
//  Created by sunil biloniya on 05/06/25.
//

import SwiftUI

final class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let queue = DispatchQueue(label: "com.movies.imagecache", qos: .userInitiated)
    
    private init() {
        // Set memory limits
        cache.countLimit = Constants.ImageCache.maxImages
        cache.totalCostLimit = Constants.ImageCache.maxMemoryLimit
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        queue.async {
            self.cache.setObject(image, forKey: key as NSString)
        }
    }
    
    func getImage(forKey key: String) -> UIImage? {
        queue.sync {
            return cache.object(forKey: key as NSString)
        }
    }
    
    func removeImage(forKey key: String) {
        queue.async {
            self.cache.removeObject(forKey: key as NSString)
        }
    }
    
    func clearCache() {
        queue.async {
            self.cache.removeAllObjects()
        }
    }
} 
