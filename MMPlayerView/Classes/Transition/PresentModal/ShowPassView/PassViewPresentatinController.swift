//
//  PassViewPresentatinController.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/17.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

public class PassViewPresentatinController: BasePresentationController {
    weak var originalPlayView:UIView?
    var lastPoint: CGPoint = .zero
    lazy var  gesture: UIPanGestureRecognizer = {
        let g = UIPanGestureRecognizer.init(target: self, action: #selector(pan(gesture:)))
        return g
    }()
    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
    }

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
        originalPlayView = self.config.playLayer?.playView
        var rect = self.containerView!.frame
        rect.size.width = 150
        rect.size.height = 100
        self.containerView?.addGestureRecognizer(gesture)
        UIView.animate(withDuration: 0.3, animations: { 
            self.containerView?.frame = rect
        }) { [unowned self] (finish) in
            let view = UIView()
            let gesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapVideo(gesture:)))
            view.addGestureRecognizer(gesture)
            view.frame = self.containerView!.bounds
            self.containerView?.addSubview(view)
            self.config.playLayer?.playView = view
            (self.config.source as? MMPlayerFromProtocol)?.presentedView(isShrinkVideo: true)
            DispatchQueue.main.async {
                self.config.playLayer?.setCoverView(enable: false)
                self.updateEndFrame(velocity: .zero)
            }
        }
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self.containerView)
        let vel = gesture.velocity(in: self.containerView)

        switch gesture.state {
        case .began:
            lastPoint = point
        case .changed:
            self.containerView?.center.x += point.x - lastPoint.x
            self.containerView?.center.y += point.y - lastPoint.y
            break
        default:
            self.updateEndFrame(velocity: vel)
            lastPoint = .zero
            break
        }
    }
    
    fileprivate func updateEndFrame(velocity: CGPoint) {
        let margin = self.config.margin
        var rect = self.containerView!.frame
        let center = self.containerView!.center
        let size = UIScreen.main.bounds
        let halfSize = size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
        var dismissVideo = false
        if center.x < halfSize.width && center.y < halfSize.height {
    
            if velocity.x < 0 {
                dismissVideo = true
                rect.origin.x = -rect.size.width
            } else {
                rect.origin.x = margin
            }
            
            rect.origin.y = margin
        } else if center.x > halfSize.width && center.y < halfSize.height {
            if velocity.x > 0 {
                dismissVideo = true
                rect.origin.x = size.width
            } else {
                rect.origin.x = size.width-rect.size.width-margin
            }
            rect.origin.y = margin
        } else if center.x < halfSize.width && center.y > halfSize.height {
            if velocity.x < 0 {
                dismissVideo = true
                rect.origin.x = -rect.size.width
            } else {
                rect.origin.x = margin
            }
            rect.origin.y = size.height-rect.size.height-margin
        } else {
            if velocity.x > 0 {
                dismissVideo = true
                rect.origin.x = size.width
            } else {
                rect.origin.x = size.width-rect.size.width-margin
            }
            rect.origin.y = size.height-rect.size.height-margin
        }
    
        UIView.animate(withDuration: self.config.duration, animations: {
            self.containerView?.frame = rect
        }) { (_) in
            if dismissVideo {
                self.config.playLayer?.coverView?.isHidden = false
                self.presentedViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func tapVideo(gesture: UITapGestureRecognizer) {
        self.config.playLayer?.playView?.removeFromSuperview()
        self.config.playLayer?.playView = originalPlayView
        
        UIView.animate(withDuration: self.config.duration, animations: { 
            self.containerView?.frame = UIScreen.main.bounds
        }) { (_) in
            
            self.config.playLayer?.setCoverView(enable: true)
        }
    }
}
