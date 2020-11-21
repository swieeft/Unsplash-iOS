//
//  CollectionController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

// MARK: - CollectionListController
class CollectionListController {
    // MARK: - Property
    let apiManager = APIManager()
    
    // 컬렉션 리스트 데이터
    var collections: CollectionModel?
    
    // 컬렉션 리스트 개수
    var collectionCount: Int {
        return collections?.count ?? 0
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
    
    // MARK: - Function
    // 이미지 리스트 데이터 호출 (첫번째 페이지)
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
    
    // 이미지 리스트 데이터 호출 (다음 페이지 호출)
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
    
    // 특정 인덱스의 컬렉션 데이터
    func collectionData(index: Int) -> CollectionItem? {
        guard let collections = self.collections, index >= 0, index < collections.count else {
            return nil
        }
        
        return collections[index]
    }
    
    // 컬렉션 타이틀
    func title(index: Int) -> String {
        guard let collection = collectionData(index: index) else {
            return ""
        }
        
        return collection.title
    }
    
    // 사진 가져오기 전 표시 할 임시 배경색
    func cellBackgroundColor(index: Int) -> UIColor {
        guard let collection = collectionData(index: index), let photo = collection.coverPhoto, let color = UIColor(hexaRGB: photo.color) else {
            return .white
        }
        
        return color
    }
    
    // 컬렉션 아이디 (컬렉션 상세 리스트 API 호출 시 필요)
    func collectionId(index: Int) -> String {
        guard let collection = collectionData(index: index) else {
            return ""
        }
        
        return collection.id
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
        guard let collection = collectionData(index: index), let photo = collection.coverPhoto else {
            return nil
        }
        
        return photo.urls.small
    }
}
