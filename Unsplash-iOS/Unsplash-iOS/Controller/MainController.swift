//
//  MainController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

protocol MainControllerDelegate: class {
    func changeHeaderImage(image: UIImage, userName: String)
}

class MainController {
    let apiManager = APIManager()
    
    var photos: PhotosModel? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("UpdatePhotos"), object: nil, userInfo: ["Photos": photos as Any])
        }
    }
    
    private var headerPhotos: PhotosModel?
    
    var photoCount: Int {
        return photos?.count ?? 0
    }
    
    private lazy var imageLoadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        return queue
    }()
    private var imageLoadOperations: [Int: ImageLoadOperation] = [:]
    private var headerImageLoadOperations: [Int: ImageLoadOperation] = [:]
    
    private var isPaging: Bool = false
    private var hasNextPage: Bool = false
    private var page: Int = 1
    
    private var currentHeaderIndex: Int = 0
    private var headerTimer: Timer?
    
    weak var delegate: MainControllerDelegate?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(pauseHeaderTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadHeaderImage), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func header() {
        apiManager.header { data in
            guard let data = data else {
                return
            }
            self.headerPhotos = data
            self.downloadHeaderImage()
        } failure: { error in
            print(error)
        }
    }
    
    func firstPage(completion: @escaping () -> (), failure: @escaping (String) -> ()) {
        self.page = 1
        apiManager.list(page: 1) { [weak self] data, hasNextPage in
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
        
        isPaging = true
        
        apiManager.list(page: self.page) { [weak self] data, hasNextPage in
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
    
    @objc private func downloadHeaderImage() {
        guard let headerPhotos = self.headerPhotos else {
            return
        }
        
        for i in 0..<headerPhotos.count {
            let photo = headerPhotos[i]
            
            let operation = ImageLoadOperation(url: photo.urls.small)
            
            operation.completion = { _ in
                self.headerImageLoadOperations.removeValue(forKey: i)
                
                if i == 0 {
                    self.startHeaderTimer()
                }
            }
            
            imageLoadQueue.addOperation(operation)
            headerImageLoadOperations[i] = operation
        }
    }
    
    private func startHeaderTimer() {
        if headerTimer?.isValid == true {
            return
        }

        headerTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            guard let photo = self.headerPhotos?[self.currentHeaderIndex],
                  let image = ImageCache.shared[photo.urls.small] else {
                return
            }
            
            let name = photo.user.firstName + (" \(photo.user.lastName ?? "")")
            
            if self.currentHeaderIndex == (self.headerPhotos?.count ?? 0) - 1 {
                self.currentHeaderIndex = 0
            } else {
                self.currentHeaderIndex += 1
            }
            
            DispatchQueue.main.async {
                self.delegate?.changeHeaderImage(image: image, userName: name)
            }
        })
        headerTimer?.fire()
    }
    
    @objc private func pauseHeaderTimer() {
        headerTimer?.invalidate()
    }
}
