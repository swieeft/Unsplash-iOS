//
//  APIEnums.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import Foundation

enum APIMethod: String {
    case get
    case post
    case put
    case delete
}

enum APIRequestType {
    case json
    case query
}

enum APIResponce {
    case success(response: ResponseSuccessModel)
    case failure(error: String)
}

enum APIResult<T: Codable> {
    case success(data: T?, hasNextPage: Bool)
    case failure(error: String)
}

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
