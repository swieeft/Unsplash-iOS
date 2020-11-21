//
//  MainListTitleTableViewCell.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

// 메인 화면 리스트의 타이틀 셀

class MainListTitleTableViewCell: UITableViewCell {
    // MARK: - UI
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Function
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setTitle(index: Int) {
        titleLabel.text = index == 0 ? "Explore" : "New"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
