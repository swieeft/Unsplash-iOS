//
//  MainLoadingView.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

class MainLoadingView: UIView {
    // MARK: - UI
    lazy var loadingLayerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /*
     각 layer 위치
        [6]
     [1]   [5]
     [2][3][4]
     */
    lazy var iconRect1Layer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 78.55, y: 29.99))
        path.addLine(to: CGPoint(x: 91.06, y: 42.5))
        path.addLine(to: CGPoint(x: 74.34, y: 59.18))
        path.addLine(to: CGPoint(x: 61.87, y: 46.67))
        path.close()
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0
        
        return layer
    }()
    
    lazy var iconRect2Layer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 66.05, y: 17.5))
        path.addLine(to: CGPoint(x: 78.56, y: 30.01))
        path.addLine(to: CGPoint(x: 61.88, y: 46.68))
        path.addLine(to: CGPoint(x: 49.37, y: 34.17))
        path.close()
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0
        
        return layer
    }()
    
    lazy var iconRect3Layer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 49.33, y: 34.2))
        path.addLine(to: CGPoint(x: 61.84, y: 46.71))
        path.addLine(to: CGPoint(x: 45.16, y: 63.38))
        path.addLine(to: CGPoint(x: 32.66, y: 50.88))
        path.close()
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0
        
        return layer
    }()
    
    lazy var iconRect4Layer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 32.69, y: 50.84))
        path.addLine(to: CGPoint(x: 45.2, y: 63.35))
        path.addLine(to: CGPoint(x: 28.53, y: 80.03))
        path.addLine(to: CGPoint(x: 16.02, y: 67.52))
        path.close()
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0
        
        return layer
    }()
    
    lazy var iconRect5Layer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 45.19, y: 63.34))
        path.addLine(to: CGPoint(x: 57.7, y: 75.85))
        path.addLine(to: CGPoint(x: 41.03, y: 92.53))
        path.addLine(to: CGPoint(x: 28.52, y: 80.02))
        path.close()
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0
        
        return layer
    }()
    
    lazy var iconRect6Layer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 84.8, y: 69.6))
        path.addLine(to: CGPoint(x: 97.31, y: 82.11))
        path.addLine(to: CGPoint(x: 80.63, y: 98.78))
        path.addLine(to: CGPoint(x: 68.13, y: 86.28))
        path.close()
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0
        
        return layer
    }()
    
    lazy var layers: [CAShapeLayer] = [iconRect1Layer, iconRect2Layer, iconRect3Layer, iconRect4Layer, iconRect5Layer, iconRect6Layer]

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    private func setUI() {
        self.addSubview(loadingLayerView)
        loadingLayerView
            .centerXAnchor(equalTo: self.centerXAnchor)
            .centerYAnchor(equalTo: self.centerYAnchor)
            .widthAnchor(equalToConstant: 130)
            .heightAnchor(equalToConstant: 130)
        
        layers.forEach { layer in
            self.loadingLayerView.layer.addSublayer(layer)
        }
    }
    
    // MARK: - Function
    func startAnimation() {
        for i in 0..<layers.count {
            let layer = layers[i]
            
            let values: [CGFloat] = (0..<5).map { _ in .random(in: 0...1) }
            
            let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.opacity))
            animation.values = values
            animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
            animation.duration = 2
            animation.isAdditive = true
            animation.repeatCount = .infinity
            
            layer.add(animation, forKey: "MainLoadingOpacityAnimantion\(i)")
        }
    }
    
    func stopAnimation() {
        loadingLayerView.layer.removeAllAnimations()
        self.removeFromSuperview()
    }
}

