//
//  CollectionController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

// MARK: - CollectionController
class CollectionController: ImageProvider {
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
    lazy var imageLoadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
    
    // 이미지 리스트 다운로드 Operation
    var imageLoadOperations: [Int: ImageLoadOperation] = [:]
    
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
}
