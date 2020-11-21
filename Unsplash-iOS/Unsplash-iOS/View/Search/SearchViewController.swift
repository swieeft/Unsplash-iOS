//
//  SearchViewController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

// MARK: - SearchViewControllerDelegate
protocol SearchViewControllerDelegate: class {
    func searchCancel()
}

// MARK: - SearchViewController
class SearchViewController: UIViewController {

    // MARK: - UI
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    
    // MARK: - Property
    let searchController = SearchController()
    
    weak var delegate: SearchViewControllerDelegate?
    
    var isKeyboardShow: Bool = false
    
    let tableViewTopInset: CGFloat = 68
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView.layer.cornerRadius = 12
        searchView.layer.masksToBounds = true
        
        searchTextField.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: tableViewTopInset, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 50
        tableView.register(CellsEnum.image.nib, forCellReuseIdentifier: CellsEnum.image.id)
        tableView.register(CellsEnum.searchTitle.nib, forCellReuseIdentifier: CellsEnum.searchTitle.id)
        tableView.register(CellsEnum.searchKeyword.nib, forCellReuseIdentifier: CellsEnum.searchKeyword.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.15) {
            self.cancelButton.isHidden = false
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.searchTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Function
    // 키보드가 나타날 때
    @objc func keyboardWillAppear(note: NSNotification) {
        if let keyboardFrame: NSValue = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            if isKeyboardShow {
                return
            }
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight: CGFloat = keyboardRectangle.height
            
            UIView.animate(withDuration: 0.25) {
                self.tableViewBottom.constant = keyboardHeight
                self.view.layoutIfNeeded()
            }
            
            isKeyboardShow = true
        }
    }
     
    // 키보드가 사라질때
    @objc func keyboardWillDisappear(note: NSNotification) {
        if isKeyboardShow == false {
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.tableViewBottom.constant = 0
            self.view.layoutIfNeeded()
        }
        
        isKeyboardShow = false
    }

    // 검색 취소
    @IBAction func cancelButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.15) {
            self.cancelButton.isHidden = true
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.delegate?.searchCancel()
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // 검색 키워드의 첫번째 호출
    func getFirstPage(keyword: String) {
        searchController.firstPage(keyword: keyword) {
            self.tableView.reloadData()
        } failure: { error in
            self.showAlert(message: error)
        }
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    // 검색
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        guard let keyword = textField.text, keyword != "" else {
            return true
        }
        
        getFirstPage(keyword: keyword)

        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.becomeFirstResponder()
        return true
    }
    
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = searchController.keywordCellCount
        tableView.alpha = count > 0 ? 1 : 0
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchController.isSearch {
            return searchController.imageHeight(index: indexPath.row) // +1은 이미지간 여백
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchController.isSearch {
            return setImageCell(tableView: tableView, indexPath: indexPath)
        } else {
            if let recentKeywords = searchController.recentKeywords, recentKeywords.count > 0, recentKeywords.count >= indexPath.row {
                return setRecentCell(tableView: tableView, indexPath: indexPath, recentKeywords: recentKeywords)
            } else {
                return setTrendingCell(tableView: tableView, indexPath: indexPath)
            }
        }
    }
    
    func setImageCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellsEnum.image.id, for: indexPath) as? ImageTableViewCell else {
            return UITableViewCell()
        }
        
        let index = indexPath.row
        
        let color = searchController.cellBackgroundColor(index: index)
        cell.setColor(color: color)
        
        let userName = searchController.userName(index: index)
        
        if let image = searchController.image(index: index) {
            cell.setImage(image: image, name: userName)
        } else {
            searchController.downloadImage(index: index) { image in
                cell.setImage(image: image, name: userName)
                self.searchController.removeImageLoadOperation(index: index)
            }
        }
        
        return cell
    }
    
    func setRecentCell(tableView: UITableView, indexPath: IndexPath, recentKeywords: [String]) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellsEnum.searchTitle.id, for: indexPath) as? SearchTitleTableViewCell else {
                return UITableViewCell()
            }
            
            cell.delegate = self
            cell.setTitle(title: .recent)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellsEnum.searchKeyword.id, for: indexPath) as? SearchKeywordTableViewCell else {
                return UITableViewCell()
            }
            
            let keyword = recentKeywords[indexPath.row - 1]
            cell.setKeyword(keyword: keyword)
            
            return cell
        }
    }
    
    func setTrendingCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        var recentKeywordsCount = searchController.recentKeywords?.count ?? 0
        recentKeywordsCount = recentKeywordsCount == 0 ? -1 : recentKeywordsCount // 검색 기록이 없을 경우에 -1을 해줘서 인덱스가 넘어가지 않도록 함
        
        if indexPath.row == (recentKeywordsCount + 1) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellsEnum.searchTitle.id, for: indexPath) as? SearchTitleTableViewCell else {
                return UITableViewCell()
            }
            
            cell.setTitle(title: .trending)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellsEnum.searchKeyword.id, for: indexPath) as? SearchKeywordTableViewCell else {
                return UITableViewCell()
            }
            
            let index = indexPath.row - recentKeywordsCount - 2
            let keyword = searchController.trendingKeyword[index]
            cell.setKeyword(keyword: keyword)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ImageTableViewCell else {
            return
        }
        
        let index = indexPath.row
        
        if let image = searchController.image(index: index) {
            cell.setImage(image: image, name: searchController.userName(index: index))
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _ = cell as? ImageTableViewCell else {
            return
        }
        
        searchController.cancelDownloadImage(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        if cell is ImageTableViewCell {
            guard let vc = ViewControllersEnum.imageDetail.viewController as? ImageDetailViewController else {
                return
            }
            
            vc.delegate = self
            vc.currentIndex = indexPath.row
            vc.imageDetailController = ImageDetailController(photos: searchController.photos)
            
            self.present(vc, animated: true, completion: nil)
        } else if let keywordCell = cell as? SearchKeywordTableViewCell {
            if let keyword = keywordCell.keywordLabel.text {
                searchTextField.text = keyword
                searchTextField.endEditing(true)
                getFirstPage(keyword: keyword)
            }
        }
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension SearchViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.searchController.downloadImage(index: indexPath.row, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            self.searchController.cancelDownloadImage(index: indexPath.row)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 테이블 뷰 페이징 처리
        if scrollView.contentOffset.y > (scrollView.contentSize.height / 2) {
            searchController.nextPage {
                self.tableView.reloadData()
            } failure: { error in
                self.showAlert(message: error)
            }
        }
    }
}

// MARK: - SearchTitleTableViewCellDelegate
extension SearchViewController: SearchTitleTableViewCellDelegate {
    // 검색 기록 삭제
    func recentClear() {
        let alert = UIAlertController(title: nil, message: "Recently Clear Search History?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            self.searchController.removeRecentKeyword()
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - ImageDetailViewControllerDelegate
extension SearchViewController: ImageDetailViewControllerDelegate {
    func changeImage(index: Int) {
        // 이미지 상세화면에서 이미지 좌/우 이동 시 해당 이미지에 맞춰서 메인 테이블 뷰의 셀 위치도 이동 시킴
        let imageHeight = searchController.imageHeight(index: index)
        let screenHeight = SizeEnum.screenHeight.value
        let statusBarHeight = SizeEnum.statusBarHeight.value
        
        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
        
        let y = (self.tableView.contentOffset.y + tableViewTopInset + statusBarHeight) - (screenHeight / 2) + (imageHeight / 2)
        self.tableView.contentOffset.y = y < 0 ? 0 : y
    }
}
