//
//  SearchCoordinator.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/12/15.
//

import UIKit

protocol SearchCoordinatorDelegate: AnyObject {
    func dismissSearch(coordinator: SearchCoordinator?)
}

class SearchCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigation: UINavigationController
    var rootViewController: SearchViewController
    
    weak var delegate: SearchCoordinatorDelegate?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
        
        let vc = SearchViewController.instantiate()
        self.rootViewController = vc
    }
    
    func start() {
        self.rootViewController.coordinator = self
        navigation.pushViewController(self.rootViewController, animated: false)
    }
    
    func dismissSearch() {
        delegate?.dismissSearch(coordinator: self)
        navigation.dismiss(animated: true, completion: nil)
    }
}
