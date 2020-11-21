//
//  MainController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

/*
    메인 화면의 데이터 컨트롤러
 */

import UIKit

// MARK: - MainControllerDelegate
protocol MainControllerDelegate: class {
    func changeHeaderImage(image: UIImage, userName: String)
}

// MARK: - MainController
class MainController {
    // MARK: - Property
    let apiManager = APIManager()
    
    // 이미지 다운로드 OperationQueue
    private lazy var imageLoadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 100
        return queue
    }()
    
    // 이미지 리스트 데이터
    var photos: PhotosModel? {
        didSet {
            // 이미지 상세화면이 열려 있을 시 데이터가 업데이트 되면 Notification을 통해 상세화면 리스트도 업데이트
            NotificationCenter.default.post(name: NSNotification.Name("UpdatePhotos"), object: nil, userInfo: ["Photos": photos as Any])
        }
    }
    
    var photoCount: Int {
        return photos?.count ?? 0
    }
    
    // 이미지 리스트 다운로드 Operation
    private var imageLoadOperations: [Int: ImageLoadOperation] = [:]

    // 페이징 데이터
    private var isPaging: Bool = false
    private var hasNextPage: Bool = false
    private var page: Int = 1
    
    // 헤더 이미지 데이터
    private var headerPhotos: PhotosModel?
    private var currentHeaderIndex: Int = 0
    
    // 헤더 이미지 다운로드 Operation
    private var headerImageLoadOperations: [Int: ImageLoadOperation] = [:]

    private var headerTimer: Timer?
    
    weak var delegate: MainControllerDelegate?
    
    // MARK: - Initialization
    init() {
        // background 진입 후 다시 foreground로 올라오면 헤더 타이머가 정상적으로 동작하지 않아 Notification 등록 하여 타이머 동작 제어
        NotificationCenter.default.addObserver(self, selector: #selector(pauseHeaderTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadHeaderImage), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - Function
    // 헤더 데이터 호출
    func header() {
        apiManager.header { data in
            guard let data = data else {
                return
            }
            self.headerPhotos = data
            self.downloadHeaderImage()
        } failure: { error in
            print(error)
        }
    }
    
    // 이미지 리스트 데이터 호출 (첫번째 페이지)
    func firstPage(completion: @escaping () -> (), failure: @escaping (String) -> ()) {
        self.page = 1
        apiManager.list(page: 1) { [weak self] data, hasNextPage in
            guard let self = self else {
                return
            }
            
            self.photos = data
            self.hasNextPage = hasNextPage
            self.page += 1
            completion()
        } failure: { error in
            failure(error)
        }
    }
    
    // 이미지 리스트 데이터 호출 (다음 페이지 호출)
    func nextPage(completion: @escaping () -> (), failure: @escaping (String) -> ()) {
        if hasNextPage == false || isPaging == true {
            return
        }
        
        isPaging = true
        
        apiManager.list(page: self.page) { [weak self] data, hasNextPage in
            guard let self = self else {
                return
            }
            
            if let data = data {
                self.photos?.append(contentsOf: data)
            }
            self.hasNextPage = hasNextPage
            self.page += 1
            self.isPaging = false
            completion()
        } failure: { error in
            self.isPaging = false
            failure(error)
        }
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
    
    // 특정 인덱스의 이미지 데이터
    func photoData(index: Int) -> Photo? {
        guard let photos = self.photos, index >= 0, index < photos.count else {
            return nil
        }
        
        return photos[index]
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
    func downloadImage(index: Int, completion: ((UIImage) -> ())?) {
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
    
    // 다운르도 할 이미지의 url 주소
    private func downloadURL(index: Int) -> String? {
        guard let photo = photoData(index: index) else {
            return nil
        }
        
        return photo.urls.small
    }
    
    // 헤더 이미지 다운로드
    @objc private func downloadHeaderImage() {
        guard let headerPhotos = self.headerPhotos else {
            return
        }
        
        for i in 0..<headerPhotos.count {
            let photo = headerPhotos[i]
            
            let operation = ImageLoadOperation(url: photo.urls.small)
            
            operation.completion = { _ in
                self.headerImageLoadOperations.removeValue(forKey: i)
                
                if i == 0 {
                    self.startHeaderTimer()
                }
            }
            
            imageLoadQueue.addOperation(operation)
            headerImageLoadOperations[i] = operation
        }
    }
    
    // 헤더 타이머 시작
    private func startHeaderTimer() {
        if headerTimer?.isValid == true {
            return
        }

        headerTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            guard let photo = self.headerPhotos?[self.currentHeaderIndex],
                  let image = ImageCache.shared[photo.urls.small] else {
                return
            }
            
            let name = photo.user.firstName + (" \(photo.user.lastName ?? "")")
            
            // 마지막 인덱스일 경우 다시 처음 이미지로 돌아감
            if self.currentHeaderIndex == (self.headerPhotos?.count ?? 0) - 1 {
                self.currentHeaderIndex = 0
            } else {
                self.currentHeaderIndex += 1
            }
            
            DispatchQueue.main.async {
                self.delegate?.changeHeaderImage(image: image, userName: name)
            }
        })
        headerTimer?.fire()
    }
    
    // 헤더 타이머 중지
    @objc private func pauseHeaderTimer() {
        headerTimer?.invalidate()
    }
}
