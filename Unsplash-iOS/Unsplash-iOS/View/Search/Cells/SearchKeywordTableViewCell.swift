//
//  SearchKeywordTableViewCell.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

class SearchKeywordTableViewCell: UITableViewCell {

    // MARK: - UI
    @IBOutlet weak var keywordLabel: UILabel!
    
    // MARK: - Function
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setKeyword(keyword: String) {
        keywordLabel.text = keyword
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
