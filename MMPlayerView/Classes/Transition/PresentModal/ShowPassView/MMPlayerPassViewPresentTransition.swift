//
//  PassViewTransition.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/16.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

class MMPlayerPassViewPresentTransition: MMPlayerBasePresentTransition, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        if self.isPresent {
            let toVC = transitionContext.viewController(forKey: .to)!
            container.addSubview(toVC.view)
            guard let passLayer = (self.source as? MMPlayerFromProtocol)?.passPlayer else {
                print("Need Called setView")
                return
            }
            guard let passContainer = (toVC as? MMPLayerToProtocol)?.containerView else {
                print("Need implement PassViewToProtocol")
                return
            }
            if let c = self.config as? MMPlayerPassViewPresentConfig {
                c.passOriginalSuper = passLayer.playView
                c.playLayer = passLayer
            }
            (self.source as? MMPlayerFromProtocol)?.transitionWillStart()
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
                pass.removeFromSuperview()
                (toVC as? MMPLayerToProtocol)?.transitionCompleted(player: passLayer)
                
            })
        } else {
            
            let from = transitionContext.viewController(forKey: .from)
            guard let config = self.config as? MMPlayerPassViewPresentConfig else {
                return
            }
            
            guard let pass = config.playLayer?.playView else {
                return
            }
            
            guard let source = (self.source as? MMPlayerPrsentFromProtocol) else {
                print("Need Implement PassViewFromProtocol")
                return
            }
            
            pass.translatesAutoresizingMaskIntoConstraints = true
            let superV = source.backReplaceSuperView?(original: config.passOriginalSuper) ?? config.passOriginalSuper
            let original:CGRect = pass.convert(pass.frame, to: nil)
            
            let convertRect:CGRect = (superV != nil ) ? superV!.convert(superV!.frame, to: nil) : .zero
            
            if superV != nil {
                pass.removeFromSuperview()
                container.addSubview(pass)
            }
            container.layoutIfNeeded()
            
            if config.dismissGesture {
                config.playLayer?.playView = nil
                config.playLayer?.layoutIfNeeded()
                pass.removeFromSuperview()
                from?.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                (self.source as? MMPlayerPrsentFromProtocol)?.dismissViewFromGesture()
                (self.source as? MMPlayerFromProtocol)?.transitionCompleted()
                config.playLayer?.clearURLWhenChangeView = true
                return
            }
            
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
                (self.source as? MMPlayerFromProtocol)?.transitionCompleted()
                config.playLayer?.clearURLWhenChangeView = true

            })
        }
    }    
}
