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
    var image: UIImage? {
        guard let url = URL(string: self.url) else {
            return nil
        }
        
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
        apiManager.downloadImage(url: self.url) { [weak self] image in
            self?.completion?(image)
        } failure: { error in
            print(error)
        }
    }
}
