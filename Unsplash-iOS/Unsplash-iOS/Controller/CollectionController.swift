//
//  CollectionController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

// MARK: - CollectionController
class CollectionController {
    // MARK: - Property
    let apiManager = APIManager()
    
    // 이미지 리스트 데이터
    var photos: PhotosModel? {
        didSet {
            // 이미지 상세화면이 열려 있을 시 데이터가 업데이트 되면 Notification을 통해 상세화면 리스트도 업데이트
            NotificationCenter.default.post(name: NSNotification.Name("UpdatePhotos"), object: nil, userInfo: ["Photos": photos as Any])
        }
    }
    
    var photoCount: Int {
        return photos?.count ?? 0
    }
    
    // 이미지 다운로드 OperationQueue
    private lazy var imageLoadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        return queue
    }()
    
    // 이미지 리스트 다운로드 Operation
    private var imageLoadOperations: [Int: ImageLoadOperation] = [:]
    
    // 페이징 데이터
    private var isPaging: Bool = false
    private var hasNextPage: Bool = false
    private var page: Int = 1
    
    
    private var id: String // 컬렉션 id (검색 시 사용)
    var title: String // 컬렉션 타이틀 (화면 상단에 표시)
    
    // MARK: - Initialization
    // 초기화 시 컬렉션의 id와 타이틀을 받아서 초기화함
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
    
    // MARK: - Function
    // 이미지 리스트 데이터 호출 (첫번째 페이지)
    func firstPage(completion: @escaping () -> (), failure: @escaping (String) -> ()) {
        self.page = 1
        apiManager.collection(id: id, page: 1) { [weak self] data, hasNextPage in
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
    
    // 이미지 리스트 데이터 호출 (다음 페이지 호출)
    func nextPage(completion: @escaping () -> (), failure: @escaping (String) -> ()) {
        if hasNextPage == false || isPaging == true {
            return
        }
        
        isPaging = true
        
        apiManager.collection(id: id, page: self.page) { [weak self] data, hasNextPage in
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
    
    // 현재 디바이스에 맞게 비율 계산 된 이미지 높이
    func imageHeight(index: Int) -> CGFloat {
        guard let photo = self.photoData(index: index) else {
            return 0
        }
        
        let ratio = photo.height / photo.width
        let height = UIScreen.main.bounds.width * ratio
        return height
    }
    
    // 이미지 업로드 유저 이름
    func userName(index: Int) -> String {
        guard let photo = self.photoData(index: index) else {
            return ""
        }
        
        let name = photo.user.firstName + (" \(photo.user.lastName ?? "")")
        return name
    }
    
    // 사진 가져오기 전 표시 할 임시 배경색
    func cellBackgroundColor(index: Int) -> UIColor {
        guard let photo = photoData(index: index), let color = UIColor(hexaRGB: photo.color) else {
            return .white
        }
        
        return color
    }
    
    // 특정 인덱스의 이미지 데이터
    func photoData(index: Int) -> Photo? {
        guard let photos = self.photos, index >= 0, index < photos.count else {
            return nil
        }
        
        return photos[index]
    }
    
    // 특정 인덱스의 이미지
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
    
    // 이미지 다운로드
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
    
    // 이미지 다운로드 취소
    func cancelDownloadImage(index: Int) {
        guard let imageLoadOperation = imageLoadOperations[index] else {
            return
        }
        
        imageLoadOperation.cancel()
        removeImageLoadOperation(index: index)
    }
    
    // 이미지 다운로드 Operation 삭제
    func removeImageLoadOperation(index: Int) {
        imageLoadOperations.removeValue(forKey: index)
    }
    
    // 다운르도 할 이미지의 url 주소
    private func downloadURL(index: Int) -> String? {
        guard let photo = photoData(index: index) else {
            return nil
        }
        
        return photo.urls.small
    }

}
