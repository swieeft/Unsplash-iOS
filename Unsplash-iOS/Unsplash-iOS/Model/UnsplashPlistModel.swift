//
//  UnsplashPlistModel.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import Foundation

// Unsplash 관련 정보 
struct UnsplashPlistModel: Codable {
    
    let unsplash: String
    
    private enum CodingKeys: String, CodingKey {
        case unsplash
    }
}
