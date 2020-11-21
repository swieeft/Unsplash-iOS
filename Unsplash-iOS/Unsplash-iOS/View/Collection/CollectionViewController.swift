//
//  CollectionViewController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

class CollectionViewController: UIViewController {
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Property
    var collectionController: CollectionController!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = collectionController.title
        
        tableView.register(CellsEnum.image.nib, forCellReuseIdentifier: CellsEnum.image.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionController.firstPage {
            self.tableView.reloadData()
        } failure: { error in
            self.showAlert(message: error)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CollectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionController.photoCount + 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return collectionController.imageHeight(index: indexPath.row) + 1 // +1은 이미지간 여백
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellsEnum.image.id, for: indexPath) as? ImageTableViewCell else {
            return UITableViewCell()
        }
        
        let index = indexPath.row
        
        let color = collectionController.cellBackgroundColor(index: index)
        cell.setColor(color: color)
        
        
        let userName = collectionController.userName(index: index)
        
        if let image = collectionController.image(index: index) {
            cell.setImage(image: image, name: userName)
        } else {
            collectionController.downloadImage(index: index) { image in
                cell.setImage(image: image, name: userName)
                self.collectionController.removeImageLoadOperation(index: index)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ImageTableViewCell else {
            return
        }
        
        let index = indexPath.row
        
        if let image = collectionController.image(index: index) {
            cell.setImage(image: image, name: collectionController.userName(index: index))
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard cell is ImageTableViewCell else {
            return
        }
        
        collectionController.cancelDownloadImage(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = ViewControllersEnum.imageDetail.viewController as? ImageDetailViewController else {
            return
        }
        
        vc.delegate = self
        vc.currentIndex = indexPath.row
        vc.imageDetailController = ImageDetailController(photos: collectionController.photos)
        
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension CollectionViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.collectionController.downloadImage(index: indexPath.row, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.collectionController.cancelDownloadImage(index: indexPath.row)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension CollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        print(offsetY)
        // 테이블 뷰 페이징 처리
        if offsetY > (scrollView.contentSize.height / 2) {
            collectionController.nextPage {
                self.tableView.reloadData()
            } failure: { error in
                self.showAlert(message: error)
            }
        }
    }
}

// MARK: - ImageDetailViewControllerDelegate
extension CollectionViewController: ImageDetailViewControllerDelegate {
    func changeImage(index: Int) {
        // 이미지 상세화면에서 이미지 좌/우 이동 시 해당 이미지에 맞춰서 메인 테이블 뷰의 셀 위치도 이동 시킴
        let imageHeight = collectionController.imageHeight(index: index)
        let screenHeight = SizeEnum.screenHeight.value
        let statusBarHeight = SizeEnum.statusBarHeight.value
        let navigationHeight = self.navigationController?.navigationBar.frame.height ?? 0
        
        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
        
        let y = (self.tableView.contentOffset.y + statusBarHeight + navigationHeight) - (screenHeight / 2) + (imageHeight / 2)
        self.tableView.contentOffset.y = y < 0 ? 0 : y
    }
}
