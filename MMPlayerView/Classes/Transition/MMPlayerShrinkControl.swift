//
//  MMPlayerShrinkControl.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2018/3/21.
//

import Foundation
class MMPlayerShrinkControl {
    lazy var  containerGesture: UIPanGestureRecognizer = {
        let g = UIPanGestureRecognizer.init(target: self, action: #selector(pan(gesture:)))
        g.isEnabled = false
        return g
    }()

    var lastPoint: CGPoint = .zero
    weak var originalPlayView:UIView?
    weak var from: UIViewController?
    weak var to: UIViewController?
    unowned let containerView: UIView
    let config: MMPlayerPresentConfig
    init(containerView: UIView, config: MMPlayerPresentConfig) {
        self.config = config
        self.containerView = containerView
    }
    
    public func shrinkView() {
        self.containerView.isUserInteractionEnabled = false
        containerGesture.isEnabled = true
        
        self.config.playLayer?.setCoverView(enable: false)
        originalPlayView = self.config.playLayer?.playView
        var rect = self.containerView.frame
        rect.size = self.config.shrinkSize
        let view = UIView(frame: CGRect(origin: .zero, size: self.config.shrinkSize))
        view.setShadow(offset: CGSize.init(width: 2, height: 2), opacity: 0.5)
        let g = UITapGestureRecognizer.init(target: self, action: #selector(self.tapVideo(gesture:)))
        view.addGestureRecognizer(g)
        from?.view.addSubview(view)
        self.config.playLayer?.playView = view
        view.addGestureRecognizer(containerGesture)
        self.setFrameWith(quadrant: .rightBottom, dismissVideo: false)
        (self.config.source as? MMPlayerFromProtocol)?.presentedView?(isShrinkVideo: true)
    }
    
    @objc func pan(gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self.config.playLayer?.playView)
        let velocity = gesture.velocity(in: self.config.playLayer?.playView)
        
        switch gesture.state {
        case .began:
            lastPoint = point
        case .changed:
            self.config.playLayer?.playView?.center.x += point.x - lastPoint.x
            self.config.playLayer?.playView?.center.y += point.y - lastPoint.y
        case .ended , .cancelled:
            let rect = self.config.playLayer?.playView?.frame ?? .zero
            let center = self.config.playLayer?.playView?.center ?? .zero
            
            let size = UIScreen.main.bounds
            let halfSize = size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
            
            if center.x < halfSize.width && center.y < halfSize.height {
                self.setFrameWith(quadrant: .leftTop, dismissVideo: velocity.x < 0 && rect.origin.x < 0)
            } else if center.x > halfSize.width && center.y < halfSize.height {
                self.setFrameWith(quadrant: .rightTop, dismissVideo: velocity.x > 0 && rect.maxX > size.width)
            } else if center.x < halfSize.width && center.y > halfSize.height {
                self.setFrameWith(quadrant: .leftBottom, dismissVideo: velocity.x < 0 && rect.origin.x < 0)
            } else if center.x > halfSize.width && center.y > halfSize.height{
                self.setFrameWith(quadrant: .rightBottom, dismissVideo: velocity.x > 0 && rect.maxX > size.width)
            }
            lastPoint = .zero
        default:
            break
        }
    }
    
    fileprivate func setFrameWith(quadrant: VideoPositionType, dismissVideo: Bool) {
        let margin = self.config.margin
        var rect = self.config.playLayer?.playView?.frame ?? .zero
        let size = UIScreen.main.bounds
        
        let safe = UIApplication.shared.keyWindow?.realSafe
        
        var safeTop: CGFloat = 0
        var safeBottom: CGFloat = 0
        if self.config.isMarginNeedArea {
            safeTop = safe?.top ?? 0
            safeBottom = safe?.bottom ?? 0
        }
        switch quadrant {
        case .leftTop:
            rect.origin.x = dismissVideo ? -rect.size.width : margin
            rect.origin.y = margin + safeTop
        case .rightTop:
            rect.origin.x = dismissVideo ? size.width : size.width-rect.size.width-margin
            rect.origin.y = margin + safeTop
        case .leftBottom:
            rect.origin.x = dismissVideo ? -rect.size.width : margin
            rect.origin.y = size.height-rect.size.height-margin-safeBottom
        case .rightBottom:
            rect.origin.x = dismissVideo ? size.width : size.width-rect.size.width-margin
            rect.origin.y = size.height-rect.size.height-margin-safeBottom
        }
        
        to?.view.alpha = 0.0
        UIView.animate(withDuration: self.config.duration, animations: {
            if dismissVideo {
                self.config.playLayer?.playView?.alpha = 0.0
            }
            self.config.playLayer?.playView?.frame = rect
        }) { [unowned self] (_) in
            if dismissVideo {
                
                (self.config as? MMPlayerPassViewPresentConfig)?._dismissGesture = true
                self.config.playLayer?.setCoverView(enable: true)
                self.to?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func tapVideo(gesture: UITapGestureRecognizer) {
        containerGesture.isEnabled = false
        if let p = self.config.playLayer?.playView {
            self.containerView.addSubview(p)
        }
        from?.fromProtocolVC?.presentedView?(isShrinkVideo: false)
        UIView.animate(withDuration: 0.3, animations: {
            self.config.playLayer?.playView?.frame = self.originalPlayView?.frame ?? .zero
            self.to?.view.alpha = 1.0
        }) { [unowned self] (_) in
            self.config.playLayer?.playView?.removeFromSuperview()
            self.config.playLayer?.playView = self.originalPlayView
            self.containerView.isUserInteractionEnabled = true
            self.config.playLayer?.setCoverView(enable: true)
        }
    }
    
    deinit {
        print("Deinit")
    }
}
