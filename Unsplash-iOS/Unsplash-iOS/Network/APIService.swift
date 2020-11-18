//
//  APIService.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import Foundation

class APIHeader {
    static let shared = APIHeader()
 
    var authorization: String {
        return authorizationKey()
    }
    
    private init() {}
    
    private func authorizationKey() -> String {
        guard let path = Bundle.main.path(forResource: "unsplash", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["unsplash"] as? String else {
            return ""
        }

        return "Client-ID \(key)"
    }
}

enum APIMethod: String {
//    case get = "GET"
//    case post = "POST"
//    case put = "PUT"
//    case delete = "DELETE"
    case get
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
            return ["Authorization": APIHeader.shared.authorization,
                    "Content-Type": "application/json"]
        }
    }
}
