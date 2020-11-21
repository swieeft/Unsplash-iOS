//
//  CollectionItemCollectionViewCell.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

class CollectionItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var collectionImageView: UIImageView!
    @IBOutlet weak var collectionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackgroundView.layer.cornerRadius = 12
        cellBackgroundView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        collectionImageView.image = nil
        collectionImageView.backgroundColor = nil
        collectionTitleLabel.text = nil
    }
    
    func setImage(image: UIImage, title: String) {
        collectionImageView.image = image
        collectionTitleLabel.text = title
    }
    
    func setColor(color: UIColor) {
        collectionImageView.backgroundColor = color
    }
}
