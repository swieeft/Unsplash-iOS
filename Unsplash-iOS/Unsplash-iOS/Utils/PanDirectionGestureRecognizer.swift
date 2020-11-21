//
//  PanDirectionGestureRecognizer.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

// PanGesture 좌/우, 상/하로만 이벤트 받을 수 있도록 한 Custom PanGesture

import UIKit

// MARK: - PanDirection Enum
enum PanDirection {
    case vertical
    case horizontal
}

// MARK: - PanDirectionGestureRecognizer
class PanDirectionGestureRecognizer: UIPanGestureRecognizer {
    // MARK: - Property
    let direction: PanDirection
    
    // MARK: - Initialization
    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }
    
    // MARK: - Function
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if state == .began {
            let vel = velocity(in: view)
            
            switch direction {
            case .horizontal where abs(vel.y) > abs(vel.x):
                state = .cancelled
            case .vertical where abs(vel.x) > abs(vel.y):
                state = .cancelled
            default:
                break
            }
        }
    }
}


