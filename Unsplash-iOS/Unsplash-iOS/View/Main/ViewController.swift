//
//  ViewController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var searchView: UIView!
    
    var alpha: CGFloat = 0 {
        didSet {
            imageView.alpha = 1 - alpha
            alphaView.alpha = alpha
            searchView.backgroundColor = UIColor.lightGray.withAlphaComponent(alpha)
        }
    }
    
    enum HeaderSize {
        case max
        case min
        
        var height: CGFloat {
            switch self {
            case .max:
                return 330
            case .min:
                return 68 + SizeEnum.statusBarHeight.value
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: HeaderSize.max.height, left: 0, bottom: 0, right: 0)
        tableView.register(CellsEnum.image.nib, forCellReuseIdentifier: CellsEnum.image.id)
        
        searchView.layer.cornerRadius = 12
        searchView.layer.masksToBounds = true
        searchView.backgroundColor = UIColor.lightGray.withAlphaComponent(0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PhotosController.shared.firstPage { [weak self] in
            self?.tableView.reloadData()
        } failure: { [weak self] error in
            self?.showAlert(message: error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PhotosController.shared.photoCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PhotosController.shared.imageHeight(index: indexPath.row) + 1 // +1은 이미지간 여백
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellsEnum.image.id, for: indexPath) as? ImageTableViewCell else {
            return UITableViewCell()
        }
        
        let index = indexPath.row
        
        if let photo = PhotosController.shared.photoData(index: index) {
            cell.setColor(color: photo.color)
            
            if let image = PhotosController.shared.image(index: index) {
                cell.setImage(image: image, name: PhotosController.shared.userName(index: index))
            } else {
                PhotosController.shared.downloadImage(index: index, url: photo.urls.small) { image in
                    cell.setImage(image: image, name: PhotosController.shared.userName(index: index))
                    PhotosController.shared.removeImageLoadOperation(index: index)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ImageTableViewCell else {
            return
        }
        
        let index = indexPath.row
        
        if let image = PhotosController.shared.image(index: index) {
            cell.setImage(image: image, name: PhotosController.shared.userName(index: index))
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        PhotosController.shared.cancelDownloadImage(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ImageDetailViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController else {
            return
        }
        
        vc.delegate = self
        vc.currentIndex = indexPath.row
        
        self.present(vc, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let index = indexPath.row
            
            if let photo = PhotosController.shared.photoData(index: index) {
                PhotosController.shared.downloadImage(index: index, url: photo.urls.small) { _ in
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            PhotosController.shared.cancelDownloadImage(index: indexPath.row)
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // HeaderView 높이 조절
        let y = HeaderSize.max.height - (offsetY + HeaderSize.max.height)
        let height = min((max(y, HeaderSize.min.height)), SizeEnum.screenHeight.value)
        
        headerViewHeight.constant = height

        // HeaderView의 Alpha 값 조절
        let alpha = 1 - (y / HeaderSize.max.height)
        switch alpha {
        case let v where v <= 0:
            self.alpha = 0
        case let v where v >= 0.95:
            self.alpha = 0.95
        default:
            self.alpha = alpha
        }
        
        // 테이블 뷰 페이징 처리
        if offsetY > (scrollView.contentSize.height / 2) {
            PhotosController.shared.nextPage { [weak self] in
                self?.tableView.reloadData()
            } failure: { [weak self] error in
                self?.showAlert(message: error)
            }
        }
    }
}

extension ViewController: ImageDetailViewControllerDelegate {
    func changeImage(index: Int) {
        // 이미지 상세화면에서 이미지 좌/우 이동 시 해당 이미지에 맞춰서 메인 테이블 뷰의 셀 위치도 이동 시킴
        let height = PhotosController.shared.imageHeight(index: index)
        
        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
        self.tableView.contentOffset.y += HeaderSize.max.height + SizeEnum.statusBarHeight.value - (SizeEnum.screenHeight.value / 2) + (height / 2)
    }
}
