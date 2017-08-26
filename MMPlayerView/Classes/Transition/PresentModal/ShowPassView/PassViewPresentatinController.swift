//
//  PassViewPresentatinController.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/17.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

enum VideoPositionType {
    case leftTop
    case rightTop
    case leftBottom
    case rightBottom
}

public class PassViewPresentatinController: BasePresentationController {
    weak var originalPlayView:UIView?
    var lastPoint: CGPoint = .zero

    lazy var  containerGesture: UIPanGestureRecognizer = {
        let g = UIPanGestureRecognizer.init(target: self, action: #selector(pan(gesture:)))
        g.isEnabled = false
        return g
    }()
    
    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        self.presentingViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.presentingViewController.view.transform = .identity
        }, completion: nil)
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        
        get {            
            return containerView?.frame ?? .zero
        } set {}
    }
    
    public func shrinkView() {
        self.containerView?.isUserInteractionEnabled = false
        containerGesture.isEnabled = true
        self.config.playLayer?.setCoverView(enable: false)
        originalPlayView = self.config.playLayer?.playView
        var rect = self.containerView?.frame ?? .zero
        rect.size = self.config.shrinkSize
        let view = UIView(frame: CGRect(origin: .zero, size: self.config.shrinkSize))
        view.setShadow(offset: CGSize.init(width: 2, height: 2), opacity: 0.5)
        let g = UITapGestureRecognizer.init(target: self, action: #selector(self.tapVideo(gesture:)))
        view.addGestureRecognizer(g)
        self.presentingViewController.view.addSubview(view)
        self.config.playLayer?.playView = view
        view.addGestureRecognizer(containerGesture)
        self.setFrameWith(quadrant: .rightBottom, dismissVideo: false)
        (self.config.source as? MMPlayerPrsentFromProtocol)?.presentedView(isShrinkVideo: true)
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
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
        switch quadrant {
        case .leftTop:
            rect.origin.x = dismissVideo ? -rect.size.width : margin
            rect.origin.y = margin
        case .rightTop:
            rect.origin.x = dismissVideo ? size.width : size.width-rect.size.width-margin
            rect.origin.y = margin
        case .leftBottom:
            rect.origin.x = dismissVideo ? -rect.size.width : margin
            rect.origin.y = size.height-rect.size.height-margin
        case .rightBottom:
            rect.origin.x = dismissVideo ? size.width : size.width-rect.size.width-margin
            rect.origin.y = size.height-rect.size.height-margin
        }

        self.presentedView?.alpha = 0.0
        UIView.animate(withDuration: self.config.duration, animations: {
            if dismissVideo {
                self.config.playLayer?.playView?.alpha = 0.0
            }
            self.config.playLayer?.playView?.frame = rect
        }) { [unowned self] (_) in
            if dismissVideo {
    
                (self.config as? PassViewPresentConfig)?._dismissGesture = true
                self.config.playLayer?.setCoverView(enable: true)
                self.presentedViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func tapVideo(gesture: UITapGestureRecognizer) {
        containerGesture.isEnabled = false
        if let p = self.config.playLayer?.playView {
            self.containerView?.addSubview(p)
        }
        (self.config.source as? MMPlayerPrsentFromProtocol)?.presentedView(isShrinkVideo: false)
        UIView.animate(withDuration: 0.3, animations: {
            self.config.playLayer?.playView?.frame = self.originalPlayView?.frame ?? .zero
            self.presentedView?.alpha = 1.0
        }) { [unowned self] (_) in
            self.config.playLayer?.playView?.removeFromSuperview()
            self.config.playLayer?.playView = self.originalPlayView
            self.containerView?.isUserInteractionEnabled = true
            self.config.playLayer?.setCoverView(enable: true)
        }
    }
    
}

