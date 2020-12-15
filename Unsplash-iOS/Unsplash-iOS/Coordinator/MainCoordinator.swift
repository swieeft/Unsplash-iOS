//
//  MainCoordinator.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/12/15.
//

import UIKit

protocol MainCoordinatorDelegate: class {
    func searchDismiss()
}

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigation: UINavigationController
    var rootViewController: MainViewController
    
    weak var delegate: MainCoordinatorDelegate?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
        
        let vc = MainViewController.instantiate()
        delegate = vc
        self.rootViewController = vc
    }
    
    func start() {
        rootViewController.coordinator = self
        navigation.pushViewController(rootViewController, animated: true)
    }
    
    func pushCollection(id: String, title: String) {
        let vc = CollectionViewController.instantiate()
        vc.collectionController = CollectionController(id: id, title: title)
        vc.coordinator = self
        
        navigation.pushViewController(vc, animated: true)
    }
    
    func showSearch() {
        let searchNavigation = UINavigationController()
        searchNavigation.modalTransitionStyle = .crossDissolve
        searchNavigation.modalPresentationStyle = .overFullScreen

        let searchCoordinator = SearchCoordinator(navigation: searchNavigation)
        searchCoordinator.delegate = self
        searchCoordinator.start()

        navigation.present(searchNavigation, animated: false, completion: nil)

        childCoordinators.append(searchCoordinator)
        print(childCoordinators.count)
    }
    
    func showAppInfo() {
        let vc = AppInfoViewController.instantiate()
        navigation.present(vc, animated: true, completion: nil)
    }
    
    func showMy() {
        let vc = MyViewController.instantiate()
        navigation.present(vc, animated: true, completion: nil)
    }
}

extension MainCoordinator: SearchCoordinatorDelegate {
    func dismissSearch(coordinator: SearchCoordinator?) {
        delegate?.searchDismiss()
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        print(childCoordinators.count)
    }
}
