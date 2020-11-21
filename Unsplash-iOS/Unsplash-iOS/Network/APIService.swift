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
    
    var method: APIMethod {
        switch self {
        case .header, .list, .search, .collectionList, .collection:
            return .get
        }
    }
    
    var request: APIRequestType {
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
            return APIHeader.get(.authorization, .contentType)
        }
    }
}
