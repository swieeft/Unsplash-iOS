//
//  CollectionTableViewCell.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

// 컬렉션 리스트 셀

// MARK: - CollectionTableViewCellDelegate
protocol CollectionTableViewCellDelegate: class {
    func collectionError(error: String)
    func selectCollection(id: String, title: String)
}

// MARK: - CollectionTableViewCell
class CollectionTableViewCell: UITableViewCell {
    
    // MARK: - UI
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Property
    private var currentIndex: CGFloat = 0
    
    private let collectionListController = CollectionListController()
    
    weak var delegate: CollectionTableViewCellDelegate?
    
    // MARK: - Function
    override func awakeFromNib() {
        super.awakeFromNib()

        // Collection View의 Cell layout 형태 및 Collection View 설정
        let cellWidth = (SizeEnum.screenWidth.value * 0.9)
        let cellHeight = SizeEnum.screenWidth.value * 0.36
        
        let insetX = (SizeEnum.screenWidth.value - cellWidth) / 2
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        collectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        collectionView.register(CellsEnum.collectionItem.nib, forCellWithReuseIdentifier: CellsEnum.collectionItem.id)
    }

    func setCollection() {
        // 컬렉션 리스트 데이터 를 가져옴
        collectionListController.firstPage {
            self.collectionView.reloadData()
        } failure: { error in
            self.delegate?.collectionError(error: error)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionListController.collectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellsEnum.collectionItem.id, for: indexPath) as? CollectionItemCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let index = indexPath.row
        
        let color = collectionListController.cellBackgroundColor(index: index)
        cell.setColor(color: color)
        
        let title = collectionListController.title(index: index)
        
        if let image = collectionListController.image(index: index) {
            cell.setImage(image: image, title: title)
        } else {
            collectionListController.downloadImage(index: index) { image in
                cell.setImage(image: image, title: title)
                self.collectionListController.removeImageLoadOperation(index: index)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CollectionItemCollectionViewCell else {
            return
        }
        
        let index = indexPath.row
        
        if let image = collectionListController.image(index: index) {
            cell.setImage(image: image, title: collectionListController.title(index: index))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        collectionListController.cancelDownloadImage(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collection = collectionListController.collectionData(index: indexPath.row) else {
            return
        }
        
        delegate?.selectCollection(id: collection.id, title: collection.title)
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension CollectionTableViewCell: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.collectionListController.downloadImage(index: indexPath.row, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.collectionListController.cancelDownloadImage(index: indexPath.row)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension CollectionTableViewCell:  UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        // 페이징
        if offsetX > (scrollView.contentSize.width * 0.7) {
            collectionListController.nextPage {
                self.collectionView.reloadData()
            } failure: { error in
                self.delegate?.collectionError(error: error)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // 컬렉션 뷰 스크롤 후 멈출 때 셀이 화면의 정 가운데로 오도록 설정
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing

        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)

        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = floor(index)
        } else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
            roundedIndex = ceil(index)
        } else {
            roundedIndex = round(index)
        }

        if currentIndex > roundedIndex {
            currentIndex -= 1
            roundedIndex = currentIndex
        } else if currentIndex < roundedIndex {
            currentIndex += 1
            roundedIndex = currentIndex
        }

        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: 0)
        targetContentOffset.pointee = offset
    }
}

