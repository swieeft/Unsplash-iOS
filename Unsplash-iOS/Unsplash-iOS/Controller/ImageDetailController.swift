//
//  ImageDetailController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

protocol ImageDetailControllerDelegate: class {
    func updatePhotos()
}

class ImageDetailController {
    let apiManager = APIManager()
    
    private(set) var photos: PhotosModel? {
        didSet {
            delegate?.updatePhotos()
        }
    }
    
    var photoCount: Int {
        return photos?.count ?? 0
    }
    
    private lazy var imageLoadQueue: OperationQueue = {
       let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 50
        return queue
    }()
    
    private var imageLoadOperations: [Int : ImageLoadOperation] = [:]
    
    weak var delegate: ImageDetailControllerDelegate?
    
    init(photos: PhotosModel?) {
        self.photos = photos
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhotos(_:)), name: NSNotification.Name("UpdatePhotos"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updatePhotos(_ notification: Notification) {
        guard let photos = notification.userInfo?["Photos"] as? PhotosModel else {
            return
        }
        
        self.photos = photos
    }
    
    func userName(index: Int) -> String {
        guard let photo = self.photoData(index: index) else {
            return ""
        }
        
        let name = photo.user.firstName + (" \(photo.user.lastName ?? "")")
        return name
    }
    
    func photoData(index: Int) -> Photo? {
        guard let photos = photos, index >= 0, index < photos.count else {
            return nil
        }
        
        return photos[index]
    }
    
    func image(index: Int) -> UIImage? {
        guard let url = downloadURL(index: index) else {
            return nil
        }
        
        if let image = ImageCache.shared[url] {
            return image
        } else {
            return nil
        }
    }
    
    func thumnailImage(index: Int) -> UIImage? {
        if let photo = photoData(index: index), let thumImage = ImageCache.shared[photo.urls.small] {
            return thumImage
        } else {
            return nil
        }
    }
    
    func downloadImage(index: Int, inProgress: ((CGFloat) -> ())?, completion: ((UIImage) -> ())?) {
        if imageLoadOperations[index] != nil {
            return
        }
        
        guard let url = downloadURL(index: index) else {
            return
        }
        
        let imageLoadOperation = ImageLoadOperation(url: url)
        imageLoadOperation.completion = { image in
            completion?(image)
        }
        
        imageLoadOperation.inProgress = { progress in
            inProgress?(progress)
        }
        
        
        
        imageLoadQueue.addOperation(imageLoadOperation)
        imageLoadOperations[index] = imageLoadOperation
    }
    
    func cancelDownloadImage(index: Int) {
        guard let imageLoadOperation = imageLoadOperations[index] else {
            return
        }
        
        imageLoadOperation.cancel()
        removeImageLoadOperation(index: index)
    }
    
    func removeImageLoadOperation(index: Int) {
        imageLoadOperations.removeValue(forKey: index)
    }
    
    private func downloadURL(index: Int) -> String? {
        guard let photo = photoData(index: index) else {
            return nil
        }
        
        return photo.urls.raw + "fm=jpg&fit=crop&w=4000&q=80&fit=max"
    }
}
