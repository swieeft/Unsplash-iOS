//
//  ResponseSuccessModel.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import Foundation

// API 통신 성공 시 전달 받을 데이터
struct ResponseSuccessModel {
    let statusCode: Int
    let data: Data
    let hasNextPage: Bool
}
