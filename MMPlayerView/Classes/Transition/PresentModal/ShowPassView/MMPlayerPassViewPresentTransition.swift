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
            toVC.view.layoutIfNeeded()
            container.addSubview(toVC.view)
            guard let fromProtocol = config.source?.fromProtocolVC else {
                    print("Need Called setView")
                    transitionContext.completeTransition(true)
                    return
            }

            guard let toProtocol = toVC.toProtocolVC else {
                print("Need Called setView")
                transitionContext.completeTransition(true)
                return
            }
            let passLayer = fromProtocol.passPlayer
            let passContainer = toProtocol.containerView

            if let c = self.config as? MMPlayerPassViewPresentConfig {
                c.passOriginalSuper = passLayer.playView
                c.playLayer = passLayer
            }
            fromProtocol.transitionWillStart()
            let convertRect:CGRect = passLayer.superlayer?.convert(passLayer.superlayer!.frame, to: nil) ?? .zero
            let convertTo = passContainer.superview?.convert(passContainer.frame, to: container) ?? .zero

            let finalFrame = transitionContext.finalFrame(for: toVC)
            let originalColor = toVC.view.backgroundColor
            let pass = UIView(frame: convertRect)
            passLayer.playView = pass
            toVC.view.backgroundColor = UIColor.clear
            toVC.view.frame = finalFrame
            pass.removeFromSuperview()
            container.addSubview(pass)
            pass.frame = convertRect
            UIView.animate(withDuration: self.config.duration, animations: {
                pass.frame = convertTo
            }, completion: { (finish) in
                toVC.view.backgroundColor = originalColor
                pass.translatesAutoresizingMaskIntoConstraints = false
                passLayer.playView = passContainer
                pass.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                toProtocol.transitionCompleted(player: passLayer)
            })
        } else {
            
            let from = transitionContext.viewController(forKey: .from)
            guard let config = self.config as? MMPlayerPassViewPresentConfig else {
                transitionContext.completeTransition(true)
                return
            }
            
            guard let pass = config.playLayer?.playView else {
                transitionContext.completeTransition(true)
                return
            }
            
            guard let source =  config.source?.fromProtocolVC  else {
                    transitionContext.completeTransition(true)
                    print("Need Implement PassViewFromProtocol")
                    return
            }
            
            guard let superV = source.backReplaceSuperView?(original: config.passOriginalSuper) ?? config.passOriginalSuper else {
                pass.translatesAutoresizingMaskIntoConstraints = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                source.transitionCompleted()
                return
            }
            pass.translatesAutoresizingMaskIntoConstraints = true
            let original:CGRect = pass.convert(pass.frame, to: nil)
            let convertRect: CGRect = superV.superview?.convert(superV.frame, to: container) ?? .zero

            pass.removeFromSuperview()
            container.addSubview(pass)
            
            if config.dismissGesture {
                pass.removeFromSuperview()
                from?.view.removeFromSuperview()                
                config.playLayer?.playView = nil
                CATransaction.setDisableActions(true)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                source.dismissViewFromGesture?()
                source.transitionCompleted()
                CATransaction.setDisableActions(false)
                return
            }
            
            pass.frame = original
            UIView.animate(withDuration: self.config.duration, animations: {
                from?.view.alpha = 0.0
                pass.frame = convertRect
            }, completion: { (finish) in
                config.playLayer?.playView = superV
                pass.translatesAutoresizingMaskIntoConstraints = false
                superV.isHidden = false
                pass.removeFromSuperview()
                from?.view.removeFromSuperview()
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                source.transitionCompleted()
            })
        }
    }    
}
