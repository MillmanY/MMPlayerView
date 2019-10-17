//
//  MMPlayerShrinkControl.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2018/3/21.
//

import Foundation
class MMPlayerShrinkControl {
    enum VideoPositionType {
        case leftTop
        case rightTop
        case leftBottom
        case rightBottom
    }

    var videoRectObserver: NSKeyValueObservation?
    lazy var  containerGesture: UIPanGestureRecognizer = {
        let g = UIPanGestureRecognizer.init(target: self, action: #selector(pan(gesture:)))
        g.isEnabled = false
        return g
    }()

    lazy var shrinkPlayView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: self.config.defaultShrinkSize))
        view.setShadow(offset: CGSize(width: 2, height: 2), opacity: 0.5)
        return view
    }()
    var currentQuadrant: VideoPositionType = .rightBottom
    var lastPoint: CGPoint = .zero
    weak var originalPlayView:UIView?
    weak var from: UIViewController?
    weak var to: UIViewController?
    unowned let containerView: UIView
    let config: MMPlayerPresentConfig
    init(containerView: UIView, config: MMPlayerPresentConfig) {
        self.config = config
        self.containerView = containerView
        let g = UITapGestureRecognizer(target: self, action: #selector(self.tapVideo(gesture:)))
        shrinkPlayView.addGestureRecognizer(g)
        shrinkPlayView.addGestureRecognizer(containerGesture)
    }
    
    public func shrinkView() {
        containerView.isUserInteractionEnabled = false
        containerGesture.isEnabled = true
        config.playLayer?.setCoverView(enable: false)
        originalPlayView = config.playLayer?.playView
        from?.view.addSubview(shrinkPlayView)
//        UIApplication.shared.keyWindow?.addSubview(shrinkPlayView)
        config.playLayer?.playView = shrinkPlayView
        (config.source as? MMPlayerFromProtocol)?.presentedView?(isShrinkVideo: true)
        videoRectObserver = config.playLayer?.observe(\.videoRect, options: [.new, .old, .initial], changeHandler: { [weak self] (_, value) in
            guard let current = self?.currentQuadrant, let new = value.newValue, (new != value.oldValue) else {
                return
            }
            self?.setFrameWith(quadrant: current, dismissVideo: false)
        })
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
        self.currentQuadrant = quadrant
        var rect = shrinkPlayView.frame
        let maxWidth = self.config.shrinkMaxWidth
        let margin = self.config.margin
        let size = UIScreen.main.bounds
        let safe = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        let safeTop: CGFloat = self.config.isMarginNeedArea ? safe.top : 0
        let safeBottom: CGFloat = self.config.isMarginNeedArea ?  safe.bottom : 0
        if let videoRectSize = self.config.playLayer?.videoRect.size, videoRectSize != .zero {
            if videoRectSize.width > videoRectSize.height {
                let height = maxWidth*videoRectSize.height/videoRectSize.width
                rect.size = CGSize(width: maxWidth, height: height)
            } else {
                let width = videoRectSize.width/videoRectSize.height*maxWidth
                rect.size = CGSize(width: width, height: maxWidth)
            }
        } else {
            rect.size = config.defaultShrinkSize
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
                self.removeVideoRectObserver()
                (self.config as? MMPlayerPassViewPresentConfig)?._dismissGesture = true
                self.config.playLayer?.setCoverView(enable: true)
                self.to?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func tapVideo(gesture: UITapGestureRecognizer) {
        self.removeVideoRectObserver()
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
    
    fileprivate func removeVideoRectObserver() {
        if let observer = videoRectObserver {
            observer.invalidate()
            self.videoRectObserver = nil
        }
    }
    
    deinit {
        self.removeVideoRectObserver()
    }
}

//
//extension MPlayerShrinkControl {
//    enum VideoPositionType {
//        case leftTop
//        case rightTop
//        case leftBottom
//        case rightBottom
//    }
//    
//    static var defaultSize = CGSize.init(width: 150, height: 100)
//}
//public class MPlayerShrinkControl {
//    var isShrink = false
//    
//    var videoRectObserver: NSKeyValueObservation?
//    lazy var  containerGesture: UIPanGestureRecognizer = {
//        let g = UIPanGestureRecognizer.init(target: self, action: #selector(pan(gesture:)))
//        return g
//    }()
//    
//    lazy var shrinkPlayView: UIView = {
//        let view = UIView.init(frame: CGRect.init(origin: .zero, size: MPlayerShrinkControl.defaultSize))
//        view.setShadow(offset: CGSize(width: 2, height: 2), opacity: 0.5)
//        return view
//    }()
//    var currentQuadrant: VideoPositionType = .rightBottom
//    var lastPoint: CGPoint = .zero
//    weak var originalPlayView:UIView?
//    let onVC: UIViewController
//    let isHiddenVC: Bool
//    let maxWidth: CGFloat
//    unowned let mmPlayerLayer: MMPlayerLayer
//    init(mmPlayerLayer: MMPlayerLayer,
//         onVC: UIViewController,
//         isHiddenVC: Bool,
//         maxWidth: CGFloat = 150) {
//        self.onVC = onVC
//        self.isHiddenVC = isHiddenVC
//        self.maxWidth = maxWidth
//        self.mmPlayerLayer = mmPlayerLayer
//        let g = UITapGestureRecognizer(target: self, action: #selector(self.tapVideo(gesture:)))
//        shrinkPlayView.addGestureRecognizer(g)
//        shrinkPlayView.addGestureRecognizer(containerGesture)
//    }
//    
//    public func shrinkView() {
//        self.onVC.presentationController?.containerView?.isUserInteractionEnabled = false
//        self.shrinkPlayView.alpha = 1.0
//        if isHiddenVC {
//            onVC.view.alpha = 0.0
//        }
//        mmPlayerLayer.setCoverView(enable: false)
//        originalPlayView = mmPlayerLayer.playView
//        UIApplication.shared.keyWindow?.addSubview(shrinkPlayView)
//        mmPlayerLayer.playView = shrinkPlayView
//        isShrink = true
//        videoRectObserver = mmPlayerLayer.observe(\.videoRect, options: [.new, .old, .initial], changeHandler: { [weak self] (_, value) in
//            guard let current = self?.currentQuadrant, let new = value.newValue, (new != value.oldValue) else {
//                return
//            }
//            self?.setFrameWith(quadrant: current, dismissVideo: false)
//        })
//    }
//    
//    public func dismissShrink() {
//        self.setFrameWith(quadrant: self.currentQuadrant, dismissVideo: true)
//    }
//    
//    @objc func pan(gesture: UIPanGestureRecognizer) {
//        let point = gesture.location(in: shrinkPlayView)
//        let velocity = gesture.velocity(in: mmPlayerLayer.playView)
//        switch gesture.state {
//        case .began:
//            lastPoint = point
//        case .changed:
//            shrinkPlayView.center.x += point.x - lastPoint.x
//            shrinkPlayView.center.y += point.y - lastPoint.y
//        case .ended , .cancelled:
//            let rect = shrinkPlayView.frame
//            let center = shrinkPlayView.center
//            
//            let size = UIScreen.main.bounds
//            let halfSize = size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
//            
//            if center.x < halfSize.width && center.y < halfSize.height {
//                self.setFrameWith(quadrant: .leftTop, dismissVideo: velocity.x < 0 && rect.origin.x < 0)
//            } else if center.x > halfSize.width && center.y < halfSize.height {
//                self.setFrameWith(quadrant: .rightTop, dismissVideo: velocity.x > 0 && rect.maxX > size.width)
//            } else if center.x < halfSize.width && center.y > halfSize.height {
//                self.setFrameWith(quadrant: .leftBottom, dismissVideo: velocity.x < 0 && rect.origin.x < 0)
//            } else if center.x > halfSize.width && center.y > halfSize.height{
//                self.setFrameWith(quadrant: .rightBottom, dismissVideo: velocity.x > 0 && rect.maxX > size.width)
//            }
//            lastPoint = .zero
//        default:
//            break
//        }
//    }
//    
//    fileprivate func setFrameWith(quadrant: VideoPositionType, dismissVideo: Bool) {
//        self.currentQuadrant = quadrant
//        var rect = shrinkPlayView.frame
//        let maxWidth: CGFloat = self.maxWidth
//        let margin: CGFloat = 10.0
//        let size = UIScreen.main.bounds
//        let safe = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
//        let safeTop: CGFloat = safe.top
//        let safeBottom: CGFloat = safe.bottom
//        let videoRectSize = mmPlayerLayer.videoRect.size
//        if videoRectSize != .zero {
//            if videoRectSize.width > videoRectSize.height {
//                let height = maxWidth*videoRectSize.height/videoRectSize.width
//                rect.size = CGSize(width: maxWidth, height: height)
//            } else {
//                let width = videoRectSize.width/videoRectSize.height*maxWidth
//                rect.size = CGSize(width: width, height: maxWidth)
//            }
//        } else {
//            rect.size = CGSize.init(width: 150, height: 100)
//        }
//        
//        switch quadrant {
//        case .leftTop:
//            rect.origin.x = dismissVideo ? -rect.size.width : margin
//            rect.origin.y = margin + safeTop
//        case .rightTop:
//            rect.origin.x = dismissVideo ? size.width : size.width-rect.size.width-margin
//            rect.origin.y = margin + safeTop
//        case .leftBottom:
//            rect.origin.x = dismissVideo ? -rect.size.width : margin
//            rect.origin.y = size.height-rect.size.height-margin-safeBottom
//        case .rightBottom:
//            rect.origin.x = dismissVideo ? size.width : size.width-rect.size.width-margin
//            rect.origin.y = size.height-rect.size.height-margin-safeBottom
//        }
//        UIView.animate(withDuration: 0.3, animations: {
//            if dismissVideo {
//                self.shrinkPlayView.alpha = 0.0
//                if self.isHiddenVC {
//                    self.onVC.view.alpha = 1.0
//                }
//            }
//            self.shrinkPlayView.frame = rect
//        }) { [unowned self] (_) in
//            if dismissVideo {
//                self.onVC.presentationController?.containerView?.isUserInteractionEnabled = true
//                self.isShrink = false
//                self.mmPlayerLayer.playView = self.originalPlayView
//                self.removeVideoRectObserver()
//                self.mmPlayerLayer.setCoverView(enable: true)
//            }
//        }
//    }
//    
//    @objc func tapVideo(gesture: UITapGestureRecognizer) {
//        guard let origin = self.originalPlayView else {
//            return
//        }
//        self.removeVideoRectObserver()
//        UIView.animate(withDuration: 0.3, animations: {
//            
//            self.shrinkPlayView.frame = origin.superview?.convert(origin.frame, to: nil) ?? .zero
//            if self.isHiddenVC {
//                self.onVC.view.alpha = 1.0
//            }
//        }) { [unowned self] (_) in
//            self.onVC.presentationController?.containerView?.isUserInteractionEnabled = true
//            self.isShrink = false
//            self.onVC.view.isHidden = false
//            self.shrinkPlayView.removeFromSuperview()
//            self.mmPlayerLayer.playView = self.originalPlayView
//            self.mmPlayerLayer.setCoverView(enable: true)
//        }
//    }
//    
//    fileprivate func removeVideoRectObserver() {
//        if let observer = videoRectObserver {
//            observer.invalidate()
//            self.videoRectObserver = nil
//        }
//    }
//    
//    deinit {
//        self.removeVideoRectObserver()
//    }
//}
//
