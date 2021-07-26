//
//  SearchTitleTableViewCell.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

// MARK: - SearchTitleTableViewCellDelegate
protocol SearchTitleTableViewCellDelegate: AnyObject {
    func recentClear()
}

// MARK: - SearchTitleTableViewCell
class SearchTitleTableViewCell: UITableViewCell {
    // MARK: - Title Enum
    enum Title: String {
        case recent = "Recent"
        case trending = "Trending"
    }
    
    // MARK: - UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    // MARK: - Property
    weak var delegate: SearchTitleTableViewCellDelegate?
    
    // MARK: - Function
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setTitle(title: Title) {
        titleLabel.text = title.rawValue
        clearButton.isHidden = title == .trending
    }

    @IBAction func clearButtonAction(_ sender: Any) {
        delegate?.recentClear()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
