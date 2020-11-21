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
    case collection
    case collectionItem
    case mainListTitle
    
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
        case .collection:
            return "CollectionTableViewCell"
        case .collectionItem:
            return "CollectionItemCollectionViewCell"
        case .mainListTitle:
            return "MainListTitleTableViewCell"
        }
    }
    
    var nib: UINib {
        return UINib(nibName: self.id, bundle: nil)
    }
}
