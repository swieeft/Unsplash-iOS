//
//  APIManager.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import UIKit

struct APIManager {
    // MARK: - Property
    private let apiRequest = APIRequest()
    
    // MARK: - Function
    // 메인 화면 헤더 이미지
    func header(completion: @escaping (PhotosModel?) -> (), failure: @escaping (String) -> ()) {
        apiRequest.request(target: .header) { response in
            let result = getResult(type: PhotosModel.self, result: response)
            
            switch result {
            case let .success(data, _):
                completion(data)
            case let .failure(error):
                failure(error)
            }
        }
    }
    
    // 메인 화면 이미지 리스트
    func list(page: Int, completion: @escaping (PhotosModel?, Bool) -> (), failure: @escaping (String) -> ()) {
        apiRequest.request(target: .list(page: page)) { response in
            let result = getResult(type: PhotosModel.self, result: response)
            
            switch result {
            case let .success(data, hasNextPage):
                completion(data, hasNextPage)
            case let .failure(error):
                failure(error)
            }
        }
    }
    
    // 이미지 검색
    func search(keyword: String, page: Int, completion: @escaping (PhotosModel?, Bool) -> (), failure: @escaping (String) -> ()) {
        apiRequest.request(target: .search(keyword: keyword, page: page)) { response in
            let result = getResult(type: SearchModel.self, result: response)
            
            switch result {
            case let .success(data, hasNextPage):
                completion(data?.results, hasNextPage)
            case let .failure(error):
                failure(error)
            }
        }
    }
    
    // 컬렉션 리스트 (메인화면의 Explore)
    func collectionList(page: Int, completion: @escaping (CollectionModel?, Bool) -> (), failure: @escaping (String) -> ()) {
        apiRequest.request(target: .collectionList(page: page)) { response in
            let result = getResult(type: CollectionModel.self, result: response)
            
            switch result {
            case let .success(data, hasNextPage):
                completion(data, hasNextPage)
            case let .failure(error):
                failure(error)
            }
        }
    }
    
    // 컬렉션 상세 이미지 리스트
    func collection(id: String, page: Int, completion: @escaping (PhotosModel?, Bool) -> (), failure: @escaping (String) -> ()) {
        apiRequest.request(target: .collection(id: id, page: page)) { response in
            let result = getResult(type: PhotosModel.self, result: response)
            
            switch result {
            case let .success(data, hasNextPage):
                completion(data, hasNextPage)
            case let .failure(error):
                failure(error)
            }
        }
    }
    
    // 이미지 다운로드
    func downloadImage(url: String, inProgress: @escaping (CGFloat) -> (), completion: @escaping (UIImage) -> (), failure: @escaping (String) -> ()) {
        apiRequest.downloadImage(url: url) { progress in
            inProgress(progress)
        } completion: { image in
            completion(image)
        } failure: { error in
            failure(error)
        }
    }
    
    func cancel() {
        apiRequest.cancel()
    }
    
    // API에서 받아온 JSON 데이터 파싱 및 에러처리
    private func getResult<T: Codable>(type: T.Type, result: APIResponce) -> APIResult<T> {
        switch result {
        case let .success(response):
                do {
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(type, from: response.data)
                    return .success(data: data, hasNextPage: response.hasNextPage)
                } catch let error {
                    let dataStr = String(data: response.data, encoding: .utf8) ?? ""
                    
                    if dataStr == "Rate Limit Exceeded" {
                        return .failure(error: dataStr)
                    } else {
                        return .failure(error: error.localizedDescription)
                    }
                }
        case let .failure(error):
            return .failure(error: error)
        }
    }
}
