//
//  Coordinator.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/12/15.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigation: UINavigationController { get set }
    
    func start()
    func showDetail(delegate: ImageDetailViewControllerDelegate, currentIndex: Int, photos: PhotosModel?)
}

extension Coordinator {
    func showDetail(delegate: ImageDetailViewControllerDelegate, currentIndex: Int, photos: PhotosModel?) {
        // 이미지 상세화면 보기
        let vc = ImageDetailViewController.instantiate()
        vc.delegate = delegate
        vc.currentIndex = currentIndex
        vc.imageDetailController = ImageDetailController(photos: photos)
        
        navigation.present(vc, animated: true, completion: nil)
    }
}
