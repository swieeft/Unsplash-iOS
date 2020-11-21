//
//  CollectionModel.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import Foundation

typealias CollectionModel = [CollectionItem]

struct CollectionItem: Codable {
    let id: String
    let title: String
    let coverPhoto: Photo?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case coverPhoto = "cover_photo"
    }
}
