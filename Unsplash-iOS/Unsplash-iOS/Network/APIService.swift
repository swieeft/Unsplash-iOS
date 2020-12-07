//
//  APIService.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import Foundation

enum APIService {
    case header
    case list(page: Int)
    case search(keyword: String, page: Int)
    case collectionList(page: Int)
    case collection(id: String, page: Int)
}

extension APIService {
    var baseURL: URL {
        return URL(string: "https://api.unsplash.com")!
    }
    
    var path: String {
        switch self {
        case .header:
            return "/photos/random"
        case .list:
            return "/photos"
        case .search:
            return "/search/photos"
        case .collectionList:
            return "/collections"
        case let .collection(id, _):
            return "/collections/\(id)/photos"
        }
    }
    
    var method: Method {
        switch self {
        case .header, .list, .search, .collectionList, .collection:
            return .get
        }
    }
    
    var request: RequestType {
        switch self {
        case .header, .list, .search, .collectionList, .collection:
            return .query
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .header:
            return ["count": 10, "featured": true, "query": "wallpaper"]
        case let .list(page):
            return ["page": page, "per_page": 30]
        case let .search(keyword, page):
            return ["query": keyword, "page": page, "per_page": 30]
        case let .collectionList(page):
            return ["page": page, "per_page": 30]
        case let .collection(_, page):
            return ["page": page, "per_page": 30]
        }
    }

    var headers: [String : String]? {
        switch self {
        case .header, .list, .search, .collectionList, .collection:
            return Header.get(.authorization, .contentType)
        }
    }
}

extension APIService {
    enum Method: String {
        case get
        case post
        case put
        case delete
    }

    enum RequestType {
        case json
        case query
    }

    enum Responce {
        case success(response: ResponseSuccessModel)
        case failure(error: String)
    }

    enum Result<T: Codable> {
        case success(data: T?, hasNextPage: Bool)
        case failure(error: String)
    }

    enum Header {
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
        
        static func get(_ headers: Header...) -> [String: String]? {
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
}
