//
//  ImageCache.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = 500
        return cache
    }()
    
    private let lock = NSLock()
    
    private init() {
    }
}

extension ImageCache {
    func image(url: String) -> UIImage? {
        lock.lock()
        
        defer {
            lock.unlock()
        }
        
        if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
            return image
        }
        
        return nil
    }
    
    func insertImage(_ image: UIImage?, url: String) {
        guard let image = image else {
            removeImage(url: url)
            return
        }
        
        let decodedImage = image.decodedImage()
        
        lock.lock()
        
        defer {
            lock.unlock()
        }
        
        imageCache.setObject(decodedImage, forKey: url as AnyObject)
    }
    
    func removeImage(url: String) {
        lock.lock()
        
        defer {
            lock.unlock()
        }
        
        imageCache.removeObject(forKey: url as AnyObject)
    }
    
    func removeAllImages() {
        lock.lock()
        
        defer {
            lock.unlock()
        }
        
        imageCache.removeAllObjects()
    }
    
    subscript(_ key: String) -> UIImage? {
        get {
            return image(url: key)
        }
        set {
            insertImage(newValue, url: key)
            return
        }
    }
}
