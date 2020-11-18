//
//  ViewController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/18.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var searchView: UIView!
    
    let headerViewMaxHeight: CGFloat = 330
    let headerViewMinHeight: CGFloat = 68 + UIApplication.shared.statusBarFrame.height
    
    var alpha: CGFloat = 0 {
        didSet {
            imageView.alpha = 1 - alpha
            alphaView.alpha = alpha
            searchView.backgroundColor = UIColor.lightGray.withAlphaComponent(alpha)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.estimatedRowHeight = 500
        tableView.contentInset = UIEdgeInsets(top: headerViewMaxHeight, left: 0, bottom: 0, right: 0)
        
        searchView.layer.cornerRadius = 12
        searchView.layer.masksToBounds = true
        searchView.backgroundColor = UIColor.lightGray.withAlphaComponent(0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let apiManager = APIManager()
        apiManager.header { data in
            print(data?.count ?? 0)
        } failure: { message in
            print(message)
        }

    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Cell \(indexPath.row)"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = headerViewMaxHeight - (scrollView.contentOffset.y + headerViewMaxHeight)
        let height = min((max(y, headerViewMinHeight)), UIScreen.main.bounds.height)
        
        headerViewHeight.constant = height
        
        let alpha = 1 - (y / headerViewMaxHeight)
        
        switch alpha {
        case let v where v <= 0:
            self.alpha = 0
        case let v where v >= 0.95:
            self.alpha = 0.95
        default:
            self.alpha = alpha
        }
    }
}
