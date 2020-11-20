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
    case searchTitle
    case searchKeyword
    
    var id: String {
        switch self {
        case .image:
            return "ImageTableViewCell"
        case .imageDetail:
            return "ImageDetailCollectionViewCell"
        case .searchTitle:
            return "SearchTitleTableViewCell"
        case .searchKeyword:
            return "SearchKeywordTableViewCell"
        }
    }
    
    var nib: UINib {
        return UINib(nibName: self.id, bundle: nil)
    }
}
