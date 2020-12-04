//
//  ImageDetailController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

// MARK: - ImageDetailControllerDelegate
protocol ImageDetailControllerDelegate: class {
    func updatePhotos()
}

// MARK: - ImageDetailController
class ImageDetailController: ImageController {
    // MARK: - Property
    let apiManager = APIManager()
    
    var photos: PhotosModel? {
        didSet {
            // 부모 리스트에서 페이징 된 데이터가 업데이트 되면 이미지 상세화면의 리스트도 Reload
            delegate?.updatePhotos()
        }
    }
    
    // 이미지 리스트 데이터
    var photoCount: Int {
        return photos?.count ?? 0
    }
    
    // 이미지 다운로드 OperationQueue
    lazy var imageLoadQueue: OperationQueue = {
       let queue = OperationQueue()
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
    
    // 이미지 리스트 다운로드 Operation
    var imageLoadOperations: [Int : ImageLoadOperation] = [:]
    
    weak var delegate: ImageDetailControllerDelegate?
    
    // MARK: - Initialization
    // 부모 리스트에 있는 이미지 리스트 데이터를 받아서 초기화함
    init(photos: PhotosModel?) {
        self.photos = photos
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhotos(_:)), name: NSNotification.Name("UpdatePhotos"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Function
    // 부모 리스트의 데이터가 업데이트 되면 이미지 상세화면의 데이터도 업데이트
    @objc func updatePhotos(_ notification: Notification) {
        guard let photos = notification.userInfo?["Photos"] as? PhotosModel else {
            return
        }
        
        self.photos = photos
    }
    
    // 상세화면용 고화질 이미지를 받아오기 전에 표시할 썸네일 이미지
    func thumnailImage(index: Int) -> UIImage? {
        if let photo = photoData(index: index), let thumImage = ImageCache.shared[photo.urls.small] {
            return thumImage
        } else {
            return nil
        }
    }
    
    // 다운르도 할 이미지의 url 주소
    func downloadURL(index: Int) -> String? {
        guard let photo = photoData(index: index) else {
            return nil
        }
        
        // 상세화면에 표시할 고화질 이미지 주소
        return photo.urls.raw + "&fm=jpg&fit=crop&w=4000&q=80&fit=max"
    }
}
