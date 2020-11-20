//
//  SearchTitleTableViewCell.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

protocol SearchTitleTableViewCellDelegate: class {
    func recentClear()
}

class SearchTitleTableViewCell: UITableViewCell {
    weak var delegate: SearchTitleTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func clearButtonAction(_ sender: Any) {
        delegate?.recentClear()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
