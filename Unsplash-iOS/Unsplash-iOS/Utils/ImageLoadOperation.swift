//
//  ImageLoadOperation.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

class ImageLoadOperation: Operation {
    var url: String
    var completion: ((UIImage) -> ())?
    var inProgress: ((CGFloat) -> ())?
    var image: UIImage? {
        return ImageCache.shared[url]
    }
    
    init(url: String) {
        self.url = url
    }
    
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
