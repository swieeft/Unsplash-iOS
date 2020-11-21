//
//  ImageTableViewCell.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

// 이미지 리스트 셀
class ImageTableViewCell: UITableViewCell {

    // MARK: - UI
    @IBOutlet weak var photosImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Function
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
    
    // 이미지 다운로드 전 표시 될 배경 색상 설정
    func setColor(color: UIColor) {
        photosImageView.backgroundColor = color
    }
    
    // 이미지, 유저 이름 설정
    func setImage(image: UIImage, name: String) {
        photosImageView.image = image
        nameLabel.text = name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
