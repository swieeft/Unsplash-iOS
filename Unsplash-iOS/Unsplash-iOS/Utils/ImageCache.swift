//
//  ImageCache.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

// 이미지 캐시

class ImageCache {
    // MARK: - Property
    static let shared = ImageCache()
    
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = 500
        return cache
    }()
    
    private let lock = NSLock()
    private let fileManager = FileManager()
    
    // MARK: - Initialization
    private init() {
    }
    
    // MARK: - Function
    func image(url: String) -> UIImage? {
        if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
            // 메모리 캐시에서 이미지를 가져옴
            return image
        } else if let filePath = diskCacheFilePath(url: url),
                  fileManager.fileExists(atPath: filePath.path) {
            
            guard let imageData = try? Data(contentsOf: filePath) else {
                return nil
            }
            
            let image = UIImage(data: imageData)
            return image
        }
        
        return nil
    }
    
    func insertImage(_ image: UIImage?, url: String) {
        guard let image = image else {
            removeImage(url: url)
            return
        }
        
        lock.lock()

        defer {
            lock.unlock()
        }
        
        // 메모리 캐시에 저장
        imageCache.setObject(image, forKey: url as AnyObject)

        // 디스크 캐시에 저장
        guard let filePath = diskCacheFilePath(url: url) else {
            return
        }
        
        if !fileManager.fileExists(atPath: filePath.path) {
            fileManager.createFile(atPath: filePath.path, contents: image.jpegData(compressionQuality: 1), attributes: nil)
        }
    }
    
    func removeImage(url: String) {
        lock.lock()

        defer {
            lock.unlock()
        }
        
        imageCache.removeObject(forKey: url as AnyObject)
        
        // 디스크 캐시에 저장 된 이미지 삭제
        guard let filePath = diskCacheFilePath(url: url) else {
            return
        }
        
        if !fileManager.fileExists(atPath: filePath.path) {
            do {
                try fileManager.removeItem(atPath: filePath.path)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func removeAllImages() {
        lock.lock()
        
        defer {
            lock.unlock()
        }
        
        imageCache.removeAllObjects()
    }
    
    // MARK: - Subscript
    subscript(_ key: String) -> UIImage? {
        get {
            return image(url: key)
        }
        set {
            insertImage(newValue, url: key)
            return
        }
    }
    
    private func diskCacheFilePath(url: String) -> URL? {
        // 디스크 캐시에 저장할 때 리스트 이미지와 상세화면 이미지를 따로 저장해야 되는데
        // url 주소는 동일하기 때문에 뒤에 url query에서 width 값으로 분기처리 함
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first,
              let imageURL = URL(string: url) else {
            return nil
        }
        
        var filePath = URL(fileURLWithPath: path)
        
        guard let query = imageURL.query else {
            filePath.appendPathComponent(imageURL.lastPathComponent)
            return filePath
        }
        
        if query.contains("w=4000") { // 상세화면 이미지
            filePath.appendPathComponent(imageURL.lastPathComponent + "Detail")
        } else if query.contains("w=400") { // 리스트 이미지
            filePath.appendPathComponent(imageURL.lastPathComponent + "List")
        } else {
            filePath.appendPathComponent(imageURL.lastPathComponent)
        }
        
        return filePath
    }
}
