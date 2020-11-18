//
//  APIManager.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import Foundation

struct APIManager {
    
    private let apiRequest = APIRequest()
    
    func header(completion: @escaping (PhotosModel?) -> (), failure: @escaping (String) -> ()) {
        apiRequest.request(target: .header) { response in
            let result = getResult(type: PhotosModel.self, result: response)
            
            switch result {
            case let .success(data):
                completion(data)
            case let .failure(error):
                failure(error)
            }
        }
    }
    
    private func getResult<T: Codable>(type: T.Type, result: APIResponce) -> APIResult<T> {
        switch result {
        case let .success(response):
                do {
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(type, from: response.data)
                    return .success(data: data)
                } catch let error {
                    print(String(data: response.data, encoding: .utf8) ?? "")
                    return .failure(error: "The data does not exist.")
                }
        case let .failure(error):
            return .failure(error: error)
        }
    }
}
