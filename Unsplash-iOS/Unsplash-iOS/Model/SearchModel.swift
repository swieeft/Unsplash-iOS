//
//  SearchModel.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import Foundation

// 검색 데이터 모델
struct SearchModel: Codable {
    let total: Int
    let totalPages: Int
    let results: PhotosModel?
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}
