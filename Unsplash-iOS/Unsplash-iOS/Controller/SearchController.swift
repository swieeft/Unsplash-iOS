//
//  SearchController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

class SearchController {
    @UserDefaultWrapper(key: UserDefaultKey.recentKeywords.key) var recentKeywords: [String]?

    let trendingKeyword: [String] = ["iPhone", "christmas", "home", "winter", "assignment"]
    
    let apiManager = APIManager()
    
    var photos: PhotosModel? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("UpdatePhotos"), object: nil, userInfo: ["Photos": photos as Any])
        }
    }
    
    var cellCount: Int {
        if isSearch {
            return photos?.count ?? 0
        } else {
            let recentKeywordsCount = recentKeywords?.count ?? 0
            return trendingKeyword.count + recentKeywordsCount + (recentKeywordsCount == 0 ? 1 : 2)
        }
    }
    
    private lazy var imageLoadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        return queue
    }()
    private var imageLoadOperations: [Int : ImageLoadOperation] = [:]
    
    private var isPaging: Bool = false
    private var hasNextPage: Bool = false
    private var page: Int = 1
    
    private var currentKeyword: String? {
        didSet {
            guard let keyword = currentKeyword else {
                return
            }
            
            if recentKeywords == nil {
                recentKeywords = [keyword]
            } else if recentKeywords?.contains(keyword) == false {
                recentKeywords?.append(keyword)
            }
        }
    }
    
    // 현재 검색 중인지 체크
    var isSearch: Bool {
        return !(currentKeyword == nil)
    }
    
    func firstPage(keyword: String, completion: @escaping () -> (), failure: @escaping (String) -> ()) {
        self.page = 1
        
        currentKeyword = keyword
        
        apiManager.search(keyword: keyword, page: 1) { [weak self] data, hasNextPage in
            guard let self = self else {
                return
            }
            
            self.photos = data
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
        
        guard let keyword = currentKeyword else {
            return
        }
        
        isPaging = true
        
        apiManager.search(keyword: keyword, page: self.page) { [weak self] data, hasNextPage in
            guard let self = self else {
                return
            }
            
            if let data = data {
                self.photos?.append(contentsOf: data)
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
    
    func removeRecentKeyword() {
        recentKeywords?.removeAll()
    }
    
    func imageHeight(index: Int) -> CGFloat {
        guard let photo = self.photoData(index: index) else {
            return 0
        }
        
        let ratio = photo.height / photo.width
        let height = UIScreen.main.bounds.width * ratio
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
    
    func photoData(index: Int) -> Photo? {
        guard let photos = self.photos, index >= 0, index < photos.count else {
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
        guard let photo = photoData(index: index) else {
            return nil
        }
        
        return photo.urls.small
    }
}
