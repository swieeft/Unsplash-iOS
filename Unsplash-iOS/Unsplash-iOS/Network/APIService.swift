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
        }
    }
    
    var method: APIMethod {
        switch self {
        case .header, .list, .search:
            return .get
        }
    }
    
    var request: APIRequestType {
        switch self {
        case .header, .list, .search:
            return .query
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .header:
            return ["count": 10]
        case let .list(page):
            return ["page": page, "per_page": 30]
        case let .search(keyword, page):
            return ["query": keyword, "page": page, "per_page": 30]
        }
    }

    var headers: [String : String]? {
        switch self {
        case .header, .list, .search:
            return APIHeader.get(.authorization, .contentType)
        }
    }
}
