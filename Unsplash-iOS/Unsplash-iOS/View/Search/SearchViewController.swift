//
//  SearchViewController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

protocol SearchViewControllerDelegate: class {
    func searchCancel()
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView.layer.cornerRadius = 12
        searchView.layer.masksToBounds = true
        
        searchTextField.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: 68, left: 0, bottom: 0, right: 0)
        tableView.register(CellsEnum.image.nib, forCellReuseIdentifier: CellsEnum.image.id)
        tableView.register(CellsEnum.searchTitle.nib, forCellReuseIdentifier: CellsEnum.searchTitle.id)
        tableView.register(CellsEnum.searchKeyword.nib, forCellReuseIdentifier: CellsEnum.searchKeyword.id)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.isHidden = false
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func cancelButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.isHidden = true
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.delegate?.searchCancel()
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchLabel.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let count = textField.text?.count, count > 0 {
            searchLabel.isHidden = true
        } else {
            searchLabel.isHidden = false
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let count = PhotosController.shared.photoCount
//        tableView.alpha = count > 0 ? 1 : 0
//        return count
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return PhotosController.shared.imageHeight(index: indexPath.row) + 1 // +1은 이미지간 여백
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellsEnum.image.id, for: indexPath) as? ImageTableViewCell else {
//            return UITableViewCell()
//        }
//
//        let index = indexPath.row
//
//        if let photo = PhotosController.shared.photoData(index: index) {
//            cell.setColor(color: photo.color)
//
//            if let image = PhotosController.shared.image(index: index, size: .list) {
//                cell.setImage(image: image, name: PhotosController.shared.userName(index: index))
//            }
//        }
//
//        return cell
        return UITableViewCell()
    }
}
