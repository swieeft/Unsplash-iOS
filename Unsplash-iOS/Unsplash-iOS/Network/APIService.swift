//
//  APIService.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import Foundation

enum APIHeader {
    case authorization
    case contentType
    
    var key: String {
        switch self {
        case .authorization:
            return "Authorization"
        case .contentType:
            return "Content-Type"
        }
    }
    
    var value: String {
        switch self {
        case .authorization:
            guard let path = Bundle.main.path(forResource: "unsplash", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path),
                  let key = dict["unsplash"] as? String else {
                return ""
            }

            return "Client-ID \(key)"
        case .contentType:
            return "application/json"
        }
    }
    
    static func get(_ headers: APIHeader...) -> [String: String]? {
        if headers.count == 0 {
            return nil
        }
        
        var header: [String: String] = [:]
        
        headers.forEach { h in
            header[h.key] = h.value
        }
        
        return header
    }
}

enum APIMethod: String {
    case get
    case post
    case put
    case delete
}

enum APIService {
    case header
}

extension APIService {
    var baseURL: URL {
        return URL(string: "https://api.unsplash.com")!
    }
    
    var path: String {
        switch self {
        case .header:
            return "/photos/random"
        }
    }
    
    var method: APIMethod {
        switch self {
        case .header:
            return .get
        }
    }
    
    var request: APIRequestType {
        switch self {
        case .header:
            return .query
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .header:
            return ["count": 10]
        }
    }

    var headers: [String : String]? {
        switch self {
        case .header:
            return APIHeader.get(.authorization, .contentType)
        }
    }
}
