//
//  APIRequest.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import UIKit

class APIRequest {
    
    private weak var task: URLSessionDataTask?
    
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
        
        task = URLSession.shared.dataTask(with: request) {[weak self] data, res, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error: error.localizedDescription))
                    self?.task = nil
                }
                return
            }
            
            guard let httpResponse = res as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(error: "Response does not exist."))
                    self?.task = nil
                }
                return
            }
            
            var hasNextPage = false
            if let link = httpResponse.allHeaderFields.filter({$0.key as? String == "Link"}).first?.value as? String {
                hasNextPage = link.contains("rel=\"next\"")
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(error: "Data does not exist."))
                    self?.task = nil
                }
                return
            }
            
            let response = ResponseSuccessModel(statusCode: httpResponse.statusCode, data: data, hasNextPage: hasNextPage)
            DispatchQueue.main.async {
                completion(.success(response: response))
                self?.task = nil
            }
        }
        task?.resume()
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
        
        task = URLSession.shared.dataTask(with: request) { [weak self] data, res, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error: error.localizedDescription))
                    self?.task = nil
                }
                return
            }
            
            guard let httpResponse = res as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(error: "Response does not exist."))
                    self?.task = nil
                }
                return
            }
            
            var hasNextPage = false
            if let link = httpResponse.allHeaderFields.filter({$0.key as? String == "Link"}).first?.value as? String {
                hasNextPage = link.contains("rel=\"next\"")
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(error: "Data does not exist."))
                    self?.task = nil
                }
                return
            }
            
            let response = ResponseSuccessModel(statusCode: httpResponse.statusCode, data: data, hasNextPage: hasNextPage)
            DispatchQueue.main.async {
                completion(.success(response: response))
                self?.task = nil
            }
        }
        task?.resume()
    }
    
    var observation: NSKeyValueObservation?
    
    func downloadImage(url urlStr: String, inProgress: @escaping (CGFloat) -> (), completion: @escaping (UIImage) -> (), failure: @escaping (String) -> ()) {
        guard let url = URL(string: urlStr) else {
            failure("Invalid URL address")
            return
        }
        
        if let image = ImageCache.shared[urlStr] {
            completion(image)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = APIMethod.get.rawValue
        
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                failure("Download image fail : \(url)")
                self?.task = nil
                return
            }
            
            ImageCache.shared[urlStr] = image
            completion(image)
            self?.task = nil
        }
        
        observation = task?.progress.observe(\.fractionCompleted, changeHandler: { progress, _ in
            inProgress(CGFloat(progress.fractionCompleted))
            if progress.fractionCompleted == 1 {
                self.observation = nil
            }
        })
        
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
}
