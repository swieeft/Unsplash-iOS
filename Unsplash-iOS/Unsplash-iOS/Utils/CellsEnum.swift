//
//  CellsEnum.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

enum CellsEnum {
    case image
    case imageDetail
    
    var id: String {
        switch self {
        case .image:
            return "ImageTableViewCell"
        case .imageDetail:
            return "ImageDetailCollectionViewCell"
        }
    }
    
    var nib: UINib {
        switch self {
        case .image:
            return UINib(nibName: "ImageTableViewCell", bundle: nil)
        case .imageDetail:
            return UINib(nibName: "ImageDetailCollectionViewCell", bundle: nil)
        }
    }
}
