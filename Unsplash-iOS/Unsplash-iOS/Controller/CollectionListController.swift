//
//  CollectionController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

class CollectionListController {
    let apiManager = APIManager()
    
    var collections: CollectionModel?
    
    var collectionCount: Int {
        return collections?.count ?? 0
    }
    
    private lazy var imageLoadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        return queue
    }()
    private var imageLoadOperations: [Int: ImageLoadOperation] = [:]
    
    private var isPaging: Bool = false
    private var hasNextPage: Bool = false
    private var page: Int = 1
    
    func firstPage(completion: @escaping () -> (), failure: @escaping (String) -> ()) {
        self.page = 1
        apiManager.collectionList(page: 1) { [weak self] data, hasNextPage in
            guard let self = self else {
                return
            }
            
            self.collections = data
            self.hasNextPage = hasNextPage
            self.page += 1
            completion()
        } failure: { error in
            failure(error)
        }
    }
    
    func nextPage(completion: @escaping () -> (), failure: @escaping (String) -> ()) {
        if hasNextPage == false || isPaging == true {
            return
        }
        
        isPaging = true
        
        apiManager.collectionList(page: self.page) { [weak self] data, hasNextPage in
            guard let self = self else {
                return
            }
            
            if let data = data {
                self.collections?.append(contentsOf: data)
            }
            self.hasNextPage = hasNextPage
            self.page += 1
            self.isPaging = false
            completion()
        } failure: { error in
            self.isPaging = false
            failure(error)
        }
    }
    
    func collectionData(index: Int) -> CollectionItem? {
        guard let collections = self.collections, index >= 0, index < collections.count else {
            return nil
        }
        
        return collections[index]
    }
    
    func title(index: Int) -> String {
        guard let collection = collectionData(index: index) else {
            return ""
        }
        
        return collection.title
    }
    
    func cellBackgroundColor(index: Int) -> UIColor {
        guard let collection = collectionData(index: index), let photo = collection.coverPhoto, let color = UIColor(hexaRGB: photo.color) else {
            return .white
        }
        
        return color
    }
    
    func collectionId(index: Int) -> String {
        guard let collection = collectionData(index: index) else {
            return ""
        }
        
        return collection.id
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
    
    private func downloadURL(index: Int) -> String? {
        guard let collection = collectionData(index: index), let photo = collection.coverPhoto else {
            return nil
        }
        
        return photo.urls.small
    }
}
