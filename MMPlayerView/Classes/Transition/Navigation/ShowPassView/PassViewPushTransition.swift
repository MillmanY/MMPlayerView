//
//  PassViewPushTransition.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/22.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

public class PassViewPushTransition: BaseNavTransition, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toVC = transitionContext.viewController(forKey: .to)!
        container.addSubview(toVC.view)

        switch self.operation {
        case .push:
            guard let passLayer = (self.source as? MMPlayerFromProtocol)?.passPlayer else {
                print("Need Called setView")
                return
            }
            guard let passContainer = (toVC as? MMPLayerToProtocol)?.containerView else {
                print("Need implement PassViewToProtocol")
                return
            }
            if let c = self.config as? PassViewPushConfig {
                c.passOriginalSuper = passLayer.playView
                c.playLayer = passLayer
            }
            let convertRect:CGRect = passLayer.superlayer?.convert(passLayer.superlayer!.frame, to: nil) ?? .zero
            let finalFrame = transitionContext.finalFrame(for: toVC)
            let originalColor = toVC.view.backgroundColor
            passLayer.clearURLWhenChangeView = false
            let pass = UIView()
            passLayer.playView = pass
            toVC.view.backgroundColor = UIColor.clear
            toVC.view.frame = finalFrame
            pass.removeFromSuperview()
            container.addSubview(pass)
            container.layoutIfNeeded()
            pass.frame = convertRect
            UIView.animate(withDuration: self.config.duration, animations: {
                pass.frame = passContainer.frame
            }, completion: { (finish) in
                pass.frame = passContainer.frame
                toVC.view.backgroundColor = originalColor
                pass.translatesAutoresizingMaskIntoConstraints = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                passLayer.playView = passContainer
                
                //
//                let f = transitionContext.viewController(forKey: .from)!
//                container.insertSubview(f.view, at: 0)
            })
        case .pop:
            let from = transitionContext.viewController(forKey: .from)
            guard let config = self.config as? PassViewPushConfig else {
                return
            }
            
            guard let pass = config.playLayer?.playView else {
                return
            }
            
            guard let source = (self.source as? MMPlayerFromProtocol) else {
                print("Need Implement PassViewFromProtocol")
                return
            }
            let superV = source.backReplaceSuperView?(original: config.passOriginalSuper) ?? config.passOriginalSuper
            let original:CGRect = pass.superview?.convert(pass.superview!.frame, to: nil) ?? .zero

            let convertRect:CGRect = (superV != nil ) ? superV!.convert(superV!.frame, to: nil) : .zero
            
            if superV != nil {
                pass.removeFromSuperview()
                container.addSubview(pass)
            }
            container.layoutIfNeeded()
            pass.translatesAutoresizingMaskIntoConstraints = true
            pass.frame = original
            UIView.animate(withDuration: self.config.duration, animations: {
                from?.view.alpha = 0.0
                pass.frame = convertRect
            }, completion: { (finish) in
                config.playLayer?.playView = superV
                pass.translatesAutoresizingMaskIntoConstraints = false
                superV?.isHidden = false
                pass.removeFromSuperview()
                from?.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                config.playLayer?.clearURLWhenChangeView = true
            })
        default:
            break
        }
    }
}
