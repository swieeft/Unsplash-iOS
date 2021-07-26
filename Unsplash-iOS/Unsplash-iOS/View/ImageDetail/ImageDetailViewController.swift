//
//  ImageDetailViewController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

// MARK: - ImageDetailViewControllerDelegate
protocol ImageDetailViewControllerDelegate: AnyObject {
    func changeImage(index: Int)
}

// MARK: - ImageDetailViewController
class ImageDetailViewController: UIViewController, Storyboarded {

    // MARK: - UI
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Property
    var imageDetailController: ImageDetailController!
    
    weak var delegate: ImageDetailViewControllerDelegate?
    
    var currentIndex: Int = 0 {
        didSet {
            delegate?.changeImage(index: currentIndex)
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(CellsEnum.imageDetail.nib, forCellWithReuseIdentifier: CellsEnum.imageDetail.id)
        
        nameLabel.text = imageDetailController.userName(index: currentIndex)
        
        imageDetailController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.performBatchUpdates(nil) { _ in
            self.collectionView.contentOffset.x = SizeEnum.screenWidth.value * CGFloat(self.currentIndex)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Function
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension ImageDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDetailController.photoCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellsEnum.imageDetail.id, for: indexPath) as? ImageDetailCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        
        let index = indexPath.row
        
        if let image = imageDetailController.image(index: index) {
            cell.photoImageView.image = image
        } else {
            cell.photoImageView.image = imageDetailController.thumnailImage(index: index)

            cell.updateProgress(progress: 0)
            
            imageDetailController.downloadImage(index: index) { progress in
                cell.updateProgress(progress: progress)
            } completion: { image in
                cell.photoImageView.image = image
                self.imageDetailController.removeImageLoadOperation(index: index)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ImageDetailCollectionViewCell else {
            return
        }
        
        let index = indexPath.row
        
        if let image = imageDetailController.image(index: index) {
            cell.photoImageView.image = image
        } else {
            cell.photoImageView.image = imageDetailController.thumnailImage(index: index)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        imageDetailController.cancelDownloadImage(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension ImageDetailViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.imageDetailController.downloadImage(index: indexPath.row, inProgress: nil, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.imageDetailController.removeImageLoadOperation(index: indexPath.row)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension ImageDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        currentIndex = index
        nameLabel.text = imageDetailController.userName(index: index)
    }
}

// MARK: - ImageDetailCollectionViewCellDelegate
extension ImageDetailViewController: ImageDetailCollectionViewCellDelegate {
    // 이미지 이동 시 배경색 Alpha 조정
    func backgroundAlpha(alpha: CGFloat) {
        backgroundView.alpha = alpha
    }
    
    // 상세화면 종료
    func dismissImageDetail() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - ImageDetailControllerDelegate
extension ImageDetailViewController: ImageDetailControllerDelegate {
    // 부모 이미지 리스트에 데이터 업데이트 시 상세화면의 데이터도 다시 reload
    func updatePhotos() {
        self.collectionView.reloadData()
    }
}
