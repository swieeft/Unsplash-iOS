//
//  SearchController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

// MARK: - SearchController
class SearchController: ImageProvider {
    // MARK: - Property
    // 최근 검색 기록
    @UserDefaultWrapper(key: UserDefaultKey.recentKeywords.key) var recentKeywords: [String]?

    let trendingKeyword: [String] = ["iPhone", "christmas", "home", "winter", "assignment"]
    
    let apiManager = APIManager()

    // 이미지 리스트 데이터
    var photos: PhotosModel? {
        didSet {
            // 이미지 상세화면이 열려 있을 시 데이터가 업데이트 되면 Notification을 통해 상세화면 리스트도 업데이트
            NotificationCenter.default.post(name: NSNotification.Name("UpdatePhotos"), object: nil, userInfo: ["Photos": photos as Any])
        }
    }
    
    // 검색 키워드 표시할 셀의 개수
    var keywordCellCount: Int {
        if isSearch {
            return photos?.count ?? 0
        } else {
            let recentKeywordsCount = recentKeywords?.count ?? 0
            return trendingKeyword.count + recentKeywordsCount + (recentKeywordsCount == 0 ? 1 : 2)
        }
    }
    
    // 이미지 다운로드 OperationQueue
    lazy var imageLoadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
    
    // 이미지 리스트 다운로드 Operation
    var imageLoadOperations: [Int : ImageLoadOperation] = [:]
    
    // 페이징 데이터
    private var isPaging: Bool = false
    private var hasNextPage: Bool = false
    private var page: Int = 1
    
    // 현재 검색 중인 키워드
    private var currentKeyword: String? {
        didSet {
            guard let keyword = currentKeyword else {
                return
            }
            
            // 키워드 검색 시 최근 검색 기록에 저장
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
    
    // MARK: - Function
    // 이미지 리스트 데이터 호출 (첫번째 페이지)
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
    
    // 이미지 리스트 데이터 호출 (다음 페이지 호출)
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
    
    // 검색 기록 삭제
    func removeRecentKeyword() {
        recentKeywords?.removeAll()
    }
}
