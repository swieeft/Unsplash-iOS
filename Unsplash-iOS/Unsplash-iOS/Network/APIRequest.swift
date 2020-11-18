//
//  APIRequest.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import Foundation

enum APIRequestType {
    case json
    case query
}

struct ResponseSuccessModel {
    let statusCode: Int
    let data: Data
}

enum APIResponce {
    case success(response: ResponseSuccessModel)
    case failure(error: String)
}

enum APIResult<T: Codable> {
    case success(data: T?)
    case failure(error: String)
}

class APIRequest {
    func request(target: APIService, completion: @escaping (APIResponce) -> ()) {
        switch target.request {
        case .json:
            requestJson(target: target, completion: completion)
        case .query:
            requestQuery(target: target, completion: completion)
        }
    }
    
    private func requestJson(target: APIService, completion: @escaping (APIResponce) -> ()) {
        let url = target.baseURL.appendingPathComponent(target.path)
        
        let json = try? JSONSerialization.data(withJSONObject: target.parameters, options: .prettyPrinted)
        
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.httpBody = json
        
        target.headers?.forEach({ (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        })
        
        let task = URLSession.shared.dataTask(with: request) { data, res, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error: error.localizedDescription))
                }
                return
            }
            
            guard let httpResponse = res as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(error: "Response does not exist."))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(error: "Data does not exist."))
                }
                return
            }
            
            let response = ResponseSuccessModel(statusCode: httpResponse.statusCode, data: data)
            completion(.success(response: response))
        }
        task.resume()
    }
    
    private func requestQuery(target: APIService, completion: @escaping (APIResponce) -> ()) {
        var urlComponents = URLComponents(url: target.baseURL.appendingPathComponent(target.path), resolvingAgainstBaseURL: true)
        
        var queryItems: [URLQueryItem] = []
        
        target.parameters.forEach { (key, value) in
            queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            return completion(.failure(error: "Invalid url address"))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        
        target.headers?.forEach({ (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        })
        
        let task = URLSession.shared.dataTask(with: request) { data, res, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error: error.localizedDescription))
                }
                return
            }
            
            guard let httpResponse = res as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(error: "Response does not exist."))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(error: "Data does not exist."))
                }
                return
            }
            
            let response = ResponseSuccessModel(statusCode: httpResponse.statusCode, data: data)
            completion(.success(response: response))
        }
        task.resume()
    }
}
