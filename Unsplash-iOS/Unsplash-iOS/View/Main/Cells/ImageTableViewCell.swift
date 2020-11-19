//
//  ImageTableViewCell.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var photosImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photosImageView.image = nil
        photosImageView.backgroundColor = .white
        nameLabel.text = nil
    }
    
    func setColor(color: String) {
        photosImageView.backgroundColor = UIColor(hexaRGB: color)
    }
    
    func setImage(image: UIImage, name: String) {
        photosImageView.image = image
        nameLabel.text = name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
