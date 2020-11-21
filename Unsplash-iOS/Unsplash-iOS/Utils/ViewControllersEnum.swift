//
//  ViewControllersEnum.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

enum ViewControllersEnum {
    case mainVC
    case imageDetail
    case search
    case collection
    
    var id: String {
        switch self {
        case .mainVC:
            return "ViewController"
        case .imageDetail:
            return "ImageDetailViewController"
        case .search:
            return "SearchViewController"
        case .collection:
            return "CollectionViewController"
        }
    }
    
    var viewController: UIViewController {
        let storyboard = UIStoryboard(name: self.id, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: self.id)
        return vc
    }
}
