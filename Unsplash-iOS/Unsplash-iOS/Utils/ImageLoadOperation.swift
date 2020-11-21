//
//  ImageLoadOperation.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

// 이미지 다운로드 Operation

class ImageLoadOperation: Operation {
    // MARK: - Property
    var url: String
    var completion: ((UIImage) -> ())?
    var inProgress: ((CGFloat) -> ())?
    
    // MARK: - Initialization
    init(url: String) {
        self.url = url
    }
    
    // MARK: - Function
    override func main() {
        if isCancelled {
            return
        }
        
        let apiManager = APIManager()
        apiManager.downloadImage(url: self.url) { [weak self] progress in
            DispatchQueue.main.async {
                self?.inProgress?(progress)
            }
        } completion: { [weak self] image in
            DispatchQueue.main.async {
                self?.completion?(image)
            }
        } failure: { error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
}
