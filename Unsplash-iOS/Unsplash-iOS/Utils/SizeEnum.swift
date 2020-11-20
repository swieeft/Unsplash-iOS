//
//  DeviceSizeEnum.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import UIKit

enum SizeEnum {
    case screenWidth
    case screenHeight
    case statusBarHeight
    case bottomMargin
    
    var value: CGFloat {
        switch self {
        case .screenWidth:
            return UIScreen.main.bounds.width
        case .screenHeight:
            return UIScreen.main.bounds.height
        case .statusBarHeight:
            return UIApplication.shared.statusBarFrame.height
        case .bottomMargin:
            if #available(iOS 13.0,  *) {
                return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0
            } else{
                return UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
            }
        }
    }
}
