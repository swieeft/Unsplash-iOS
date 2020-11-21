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
    
    lazy var loadingView: MainLoadingView = {
        let view = MainLoadingView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    private var searchViewTapCurrentOffset: CGFloat?
    
    let mainController = MainController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: HeaderSize.max.height, left: 0, bottom: 0, right: 0)
        tableView.register(CellsEnum.image.nib, forCellReuseIdentifier: CellsEnum.image.id)
        
        searchView.layer.cornerRadius = 12
        searchView.layer.masksToBounds = true
        searchView.backgroundColor = UIColor.lightGray.withAlphaComponent(0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchViewTapAction(_:)))
        searchView.isUserInteractionEnabled = true
        searchView.addGestureRecognizer(tapGesture)
        
        self.view.addSubview(loadingView)
        loadingView
            .topAnchor(equalTo: self.view.topAnchor)
            .bottomAnchor(equalTo: self.view.bottomAnchor)
            .leadingAnchor(equalTo: self.view.leadingAnchor)
            .trailingAnchor(equalTo: self.view.trailingAnchor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingView.startAnimation()
        
        mainController.firstPage {
            self.tableView.reloadData()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.5) {
                    self.loadingView.alpha = 0
                } completion: { _ in
                    self.loadingView.stopAnimation()
                }
            }
        } failure: { error in
            self.showAlert(message: error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func searchViewTapAction(_ gesture: UITapGestureRecognizer) {
        let topOffsetY = -1 * HeaderSize.min.height
        
        if tableView.contentOffset.y > topOffsetY {
            guard let vc = ViewControllersEnum.search.viewController as? SearchViewController else {
                return
            }
            
            self.present(vc, animated: false, completion: nil)
        } else {
            searchViewTapCurrentOffset = self.tableView.contentOffset.y
            
            UIView.animate(withDuration: 0.3) {
                self.tableView.contentOffset.y = topOffsetY
                self.view.layoutIfNeeded()
            } completion: { _ in
                guard let vc = ViewControllersEnum.search.viewController as? SearchViewController else {
                    return
                }
                
                vc.delegate = self
                
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainController.photoCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return mainController.imageHeight(index: indexPath.row) + 1 // +1은 이미지간 여백
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellsEnum.image.id, for: indexPath) as? ImageTableViewCell else {
            return UITableViewCell()
        }
        
        let index = indexPath.row
        
        let color = mainController.cellBackgroundColor(index: index)
        cell.setColor(color: color)
    
        
        let userName = mainController.userName(index: index)
        
        if let image = mainController.image(index: index) {
            cell.setImage(image: image, name: userName)
        } else {
            mainController.downloadImage(index: index) { image in
                cell.setImage(image: image, name: userName)
                self.mainController.removeImageLoadOperation(index: index)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ImageTableViewCell else {
            return
        }
        
        let index = indexPath.row
        
        if let image = mainController.image(index: index) {
            cell.setImage(image: image, name: mainController.userName(index: index))
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        mainController.cancelDownloadImage(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = ViewControllersEnum.imageDetail.viewController as? ImageDetailViewController else {
            return
        }
        
        vc.delegate = self
        vc.currentIndex = indexPath.row
        vc.imageDetailController = ImageDetailController(photos: mainController.photos)
        
        self.present(vc, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.mainController.downloadImage(index: indexPath.row, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.mainController.cancelDownloadImage(index: indexPath.row)
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
        if offsetY > (scrollView.contentSize.height - scrollView.frame.height) {
            mainController.nextPage {
                self.tableView.reloadData()
            } failure: { error in
                self.showAlert(message: error)
            }
        }
    }
}

extension ViewController: ImageDetailViewControllerDelegate, SearchViewControllerDelegate {
    func searchCancel() {
        guard let offsetY = self.searchViewTapCurrentOffset else {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.contentOffset.y = offsetY
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.searchViewTapCurrentOffset = nil
        }
    }
    
    func changeImage(index: Int) {
        // 이미지 상세화면에서 이미지 좌/우 이동 시 해당 이미지에 맞춰서 메인 테이블 뷰의 셀 위치도 이동 시킴
        let height = mainController.imageHeight(index: index)
        
        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
        self.tableView.contentOffset.y += HeaderSize.max.height + SizeEnum.statusBarHeight.value - (SizeEnum.screenHeight.value / 2) + (height / 2)
    }
}
