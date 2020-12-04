//
//  ImageDownloadController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/12/03.
//

import UIKit

protocol ImageController : class {
    var photos: PhotosModel? { get set }
    var imageLoadQueue: OperationQueue { get set }
    var imageLoadOperations: [Int: ImageLoadOperation] { get set }
    
    func firstPage(completion: @escaping () -> (), failure: @escaping (String) -> ())
    func nextPage(completion: @escaping () -> (), failure: @escaping (String) -> ())
    func photoData(index: Int) -> Photo?
    func imageHeight(index: Int) -> CGFloat
    func userName(index: Int) -> String
    func cellBackgroundColor(index: Int) -> UIColor
    func image(index: Int) -> UIImage?
    func downloadImage(index: Int, completion: ((UIImage) -> ())?)
    func cancelDownloadImage(index: Int)
    func removeImageLoadOperation(index: Int)
    func downloadURL(index: Int) -> String?
}

extension ImageController {
    func photoData(index: Int) -> Photo? {
        guard let photos = self.photos, index >= 0, index < photos.count else {
            return nil
        }
        
        return photos[index]
    }
    
    func imageHeight(index: Int) -> CGFloat {
        guard let photo = self.photoData(index: index) else {
            return 0
        }
        
        let ratio = photo.height / photo.width
        let height = SizeEnum.screenWidth.value * ratio
        return height
    }
    
    func userName(index: Int) -> String {
        guard let photo = self.photoData(index: index) else {
            return ""
        }
        
        let name = photo.user.firstName + (" \(photo.user.lastName ?? "")")
        return name
    }
    
    func cellBackgroundColor(index: Int) -> UIColor {
        guard let photo = photoData(index: index), let color = UIColor(hexaRGB: photo.color) else {
            return .white
        }
        
        return color
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
    
    func downloadImage(index: Int, completion: ((UIImage) -> ())?) {
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
    
    func downloadURL(index: Int) -> String? {
        guard let photo = photoData(index: index) else {
            return nil
        }
        
        return photo.urls.small
    }
}
