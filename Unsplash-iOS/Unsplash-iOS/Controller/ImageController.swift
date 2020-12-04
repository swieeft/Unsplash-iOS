//
//  ImageDownloadController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/12/03.
//

import UIKit

protocol ImageController : class {
    var photos: PhotosModel? { get set }
    var imageLoadQueue: OperationQueue { get set }
    var imageLoadOperations: [Int: ImageLoadOperation] { get set }
    
    func photoData(index: Int) -> Photo?
    func imageHeight(index: Int) -> CGFloat
    func userName(index: Int) -> String
    func cellBackgroundColor(index: Int) -> UIColor
    func image(index: Int) -> UIImage?
    func downloadImage(index: Int, inProgress: ((CGFloat) -> ())?, completion: ((UIImage) -> ())?)
    func cancelDownloadImage(index: Int)
    func removeImageLoadOperation(index: Int)
    func downloadURL(index: Int) -> String?
}

extension ImageController {
    // 특정 인덱스의 이미지 데이터
    func photoData(index: Int) -> Photo? {
        guard let photos = self.photos, index >= 0, index < photos.count else {
            return nil
        }
        
        return photos[index]
    }
    
    // 현재 디바이스에 맞게 비율 계산 된 이미지 높이
    func imageHeight(index: Int) -> CGFloat {
        guard let photo = self.photoData(index: index) else {
            return 0
        }
        
        let ratio = photo.height / photo.width
        let height = SizeEnum.screenWidth.value * ratio
        return height
    }
    
    // 이미지 업로드 유저 이름
    func userName(index: Int) -> String {
        guard let photo = self.photoData(index: index) else {
            return ""
        }
        
        let name = photo.user.firstName + (" \(photo.user.lastName ?? "")")
        return name
    }
    
    // 사진 가져오기 전 표시 할 임시 배경색
    func cellBackgroundColor(index: Int) -> UIColor {
        guard let photo = photoData(index: index), let color = UIColor(hexaRGB: photo.color) else {
            return .white
        }
        
        return color
    }
    
    // 특정 인덱스의 이미지
    func image(index: Int) -> UIImage? {
        guard let url = downloadURL(index: index) else {
            return nil
        }
        
        if let image = ImageCache.shared[url] {
            return image
        } else {
            return nil
        }
    }
    
    // 이미지 다운로드
    func downloadImage(index: Int, inProgress: ((CGFloat) -> ())? = nil, completion: ((UIImage) -> ())?) {
        if imageLoadOperations[index] != nil {
            return
        }
        
        guard let url = downloadURL(index: index) else {
            return
        }
        
        let imageLoadOperation = ImageLoadOperation(url: url)
        imageLoadOperation.completion = { image in
            completion?(image)
        }
        
        imageLoadOperation.inProgress = { progress in
            inProgress?(progress)
        }
        
        imageLoadQueue.addOperation(imageLoadOperation)
        imageLoadOperations[index] = imageLoadOperation
    }
    
    // 이미지 다운로드 취소
    func cancelDownloadImage(index: Int) {
        guard let imageLoadOperation = imageLoadOperations[index] else {
            return
        }
        
        imageLoadOperation.cancel()
        removeImageLoadOperation(index: index)
    }
    
    // 이미지 다운로드 Operation 삭제
    func removeImageLoadOperation(index: Int) {
        imageLoadOperations.removeValue(forKey: index)
    }
    
    // 다운로드 할 이미지의 url 주소
    func downloadURL(index: Int) -> String? {
        guard let photo = photoData(index: index) else {
            return nil
        }
        
        return photo.urls.small
    }
}
