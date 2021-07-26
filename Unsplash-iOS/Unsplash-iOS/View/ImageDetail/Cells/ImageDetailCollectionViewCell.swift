//
//  ImageDetailCollectionViewCell.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/19.
//

import UIKit

// MARK: - ImageDetailCollectionViewCellDelegate
protocol ImageDetailCollectionViewCellDelegate: AnyObject {
    func backgroundAlpha(alpha: CGFloat)
    func dismissImageDetail()
}

// MARK: - ImageDetailCollectionViewCell
class ImageDetailCollectionViewCell: UICollectionViewCell {

    // MARK: - UI
    // 이미지 Zoom을 위한 스크롤 뷰
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.zoomScale = 1.0
        scrollView.backgroundColor = .clear
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        // 이미지 뷰 이동 제스처
        let panGesture = PanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(moveImageAction(_:)))
        imageView.addGestureRecognizer(panGesture)
        self.panGesture = panGesture
        
        // 이미지 뷰 더블 탭 제스처 (Zoom)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(zoomImageAction(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
        
        return imageView
    }()
    
    // 상세 이미지 다운로드 진행률을 표시할 뷰
    lazy var progressView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: (SizeEnum.screenHeight.value - SizeEnum.bottomMargin.value - 60), width: 60, height: 60))
        view.backgroundColor = .clear//UIColor.darkGray.withAlphaComponent(0.6)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    // 상세 이미지 다운로드 진행률을 표시할 라벨 (백분률 표시)
    lazy var progressLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        label.textAlignment = .center
        label.text = "0%"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 11)
        return label
    }()
    
    // 상세 이미지 다운로드 진행률을 표시할 Layer (원형으로 진행률 표시)
    lazy var progressLayer: CAShapeLayer = {
        let path = UIBezierPath(arcCenter: CGPoint(x: 30, y: 30), radius: 20, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineWidth = 2
        layer.strokeEnd = 0
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.fillMode = .forwards
        
        return layer
    }()
    
    private var panGesture: UIPanGestureRecognizer? // 이미지 뷰 이동 제스처
    
    var delegate: ImageDetailCollectionViewCellDelegate?
    
    // MARK: - Function
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.addSubview(scrollView)
        scrollView.addSubview(photoImageView)
        
        self.contentView.addSubview(progressView)
        progressView.addSubview(progressLabel)
        progressView.layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        scrollView.zoomScale = 1.0
        photoImageView.image = nil
        progressView.isHidden = true
        progressLabel.text = "0%"
        progressLayer.strokeEnd = 0
    }
    
    // 이미지 이동
    @objc private func moveImageAction(_ sender: UIPanGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else {
            return
        }
        
        let translation = sender.translation(in: self)
        
        let y = translation.y > 0 ? translation.y : (-1 * translation.y)
        let alpha = 1.0 - (y / (self.frame.height / 2))
        
        switch sender.state {
        case .began:
            break
        case .changed:
            imageView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            
            // 아래로 내릴때만 배경색 Alpha 변경
            if translation.y > 0 {
                delegate?.backgroundAlpha(alpha: alpha)
            }
        case .ended:
            // 이미지 드래그 종료 시 이미지 위치에 따라 원래 위치로 돌리거나, 상세화면 종료
            if alpha < 0.7 && translation.y > 0 {
                delegate?.dismissImageDetail()
            } else {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    imageView.transform = .identity
                    self?.delegate?.backgroundAlpha(alpha: 1)
                }
            }
        default:
            break
        }
    }
    
    // 더블 탭 시 이미지 줌 인/아웃
    @objc private func zoomImageAction(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.zoomScale = self.scrollView.zoomScale == 1.0 ? 4.0 : 1.0
        }) { _ in
            self.panGesture?.isEnabled = self.scrollView.zoomScale == 1.0 ? true : false
        }
    }
    
    // 상세 이미지 다운로드 진행률 표시
    func updateProgress(progress: CGFloat) {
        progressView.isHidden = false
        
        let percent = Int(progress * 100)
        progressLabel.text = "\(percent)%"
        
        progressLayer.strokeEnd = progress
        
        if progress == 1.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.progressView.isHidden = true
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension ImageDetailCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = photoImageView.image {
                let ratioWidth = photoImageView.frame.width / image.size.width
                let ratioHeight = photoImageView.frame.height / image.size.height
                
                let ratio = ratioWidth < ratioHeight ? ratioWidth : ratioHeight
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                
                let conditionLeft = (newWidth * scrollView.zoomScale) > photoImageView.frame.width
                let left = 0.5 * (conditionLeft ? (newWidth - photoImageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                
                let conditionTop = (newHeight * scrollView.zoomScale) > photoImageView.frame.height
                let top = 0.5 * (conditionTop ? (newHeight - photoImageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        panGesture?.isEnabled = scale == 1.0 ? true : false
    }
}
