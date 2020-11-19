//
//  UIImageExtension.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

extension UIImage {
    // 서버에서 받아온 이미지를 렌더링하여 화면에 반영되는 시간 성능을 개선함 (단, 압축을 해제하기 때문에 메모리 사용량은 늘어남)
    func decodedImage() -> UIImage {
        guard let cgImage = cgImage else {
            return self
        }
        
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: cgImage.bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        guard let decodedImage = context?.makeImage() else {
            return self
        }
        
        return UIImage(cgImage: decodedImage)
    }
}
