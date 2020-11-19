//
//  APIManager.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import UIKit

struct APIManager {
    private let apiRequest = APIRequest()
    
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
    
    func downloadImage(url: String, completion: @escaping (UIImage) -> (), failure: @escaping (String) -> ()) {
        apiRequest.downloadImage(url: url) { image in
            completion(image)
        } failure: { error in
            failure(error)
        }
    }
    
    func cancel() {
        apiRequest.cancel()
    }
    
    private func getResult<T: Codable>(type: T.Type, result: APIResponce) -> APIResult<T> {
        switch result {
        case let .success(response):
                do {
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(type, from: response.data)
                    return .success(data: data, hasNextPage: response.hasNextPage)
                } catch let error {
                    print(String(data: response.data, encoding: .utf8) ?? "")
                    return .failure(error: error.localizedDescription)
                }
        case let .failure(error):
            return .failure(error: error)
        }
    }
}
