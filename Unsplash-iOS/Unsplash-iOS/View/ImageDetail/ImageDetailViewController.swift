//
//  ImageDetailViewController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

protocol ImageDetailViewControllerDelegate: class {
    func changeImage(index: Int)
}

class ImageDetailViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var delegate: ImageDetailViewControllerDelegate?
    
    var currentIndex: Int = 0 {
        didSet {
            delegate?.changeImage(index: currentIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "ImageDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageDetailCollectionViewCell")
        
        nameLabel.text = PhotosController.shared.userName(index: currentIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.performBatchUpdates(nil) { _ in
            self.collectionView.contentOffset.x = UIScreen.main.bounds.width * CGFloat(self.currentIndex)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ImageDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotosController.shared.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageDetailCollectionViewCell", for: indexPath) as? ImageDetailCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        
        let index = indexPath.row
        
        if let image = PhotosController.shared.image(index: index) {
            cell.photoImageView.image = image
        } else {
            if let photo = PhotosController.shared.photoData(index: index) {
                PhotosController.shared.downloadImage(index: index, url: photo.urls.small) { image in
                    cell.photoImageView.image = image
                    PhotosController.shared.removeImageLoadOperation(index: index)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ImageDetailCollectionViewCell else {
            return
        }
        
        let index = indexPath.row
        
        if let image = PhotosController.shared.image(index: index) {
            cell.photoImageView.image = image
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        PhotosController.shared.cancelDownloadImage(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

extension ImageDetailViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let index = indexPath.row
            
            if let photo = PhotosController.shared.photoData(index: index) {
                PhotosController.shared.downloadImage(index: index, url: photo.urls.small) { _ in
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            PhotosController.shared.removeImageLoadOperation(index: indexPath.row)
        }
    }
}

extension ImageDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let contentOffsetX = scrollView.contentOffset.x
        
        let offsetX = contentOffsetX / width
        let index = Int(round(offsetX))
        
        currentIndex = index
        nameLabel.text = PhotosController.shared.userName(index: index)
    }
}

extension ImageDetailViewController: ImageDetailCollectionViewCellDelegate {
    func backgroundAlpha(alpha: CGFloat) {
        backgroundView.alpha = alpha
    }
    
    func dismissImageDetail() {
        self.dismiss(animated: true, completion: nil)
    }
}
