//
//  PassViewPushTransition.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/22.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

public class MMPlayerPassViewPushTransition: MMPlayerBaseNavTransition, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toVC = transitionContext.viewController(forKey: .to)!
        container.addSubview(toVC.view)

        switch self.operation {
        case .push:
            toVC.view.layoutIfNeeded()
            
            guard let from = transitionContext.viewController(forKey: .from),
                let fromProtocol = from.fromProtocolVC else {
                    print("From protocol not found")
                    transitionContext.completeTransition(true)
                    return
            }

            guard let toProtocol = toVC.toProtocolVC else {
                    print("To Protocol not found")
                transitionContext.completeTransition(true)
                return
            }

            let passLayer = fromProtocol.passPlayer
            let passContainer = toProtocol.containerView
            
            if let c = self.config as? MMPlayerPassViewPushConfig {
                c.passOriginalSuper = passLayer.playView
                c.playLayer = passLayer
            }
            fromProtocol.transitionWillStart()
            let convertRect:CGRect = passLayer.superlayer?.convert(passLayer.superlayer!.frame, to: nil) ?? .zero
            let finalFrame = transitionContext.finalFrame(for: toVC)
            let originalColor = toVC.view.backgroundColor
            passLayer.clearURLWhenChangeView = false
            let pass = UIView(frame: convertRect)
            passLayer.playView = pass
            toVC.view.backgroundColor = UIColor.clear
            toVC.view.frame = finalFrame
            pass.removeFromSuperview()
            container.addSubview(pass)
            pass.frame = convertRect
            UIView.animate(withDuration: self.config.duration, animations: {
                pass.frame = passContainer.frame
            }, completion: { (finish) in
                pass.frame = passContainer.frame
                toVC.view.backgroundColor = originalColor
                pass.translatesAutoresizingMaskIntoConstraints = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                passLayer.playView = passContainer
                toProtocol.transitionCompleted(player: passLayer)
                passLayer.clearURLWhenChangeView = true
            })
        case .pop:
            let from = transitionContext.viewController(forKey: .from)
            
            guard let config = self.config as? MMPlayerPassViewPushConfig else {
                transitionContext.completeTransition(true)
                return
            }
    
            guard let pass = config.playLayer?.playView else {
                transitionContext.completeTransition(true)
                return
            }
            
            guard let to = transitionContext.viewController(forKey: .to),
                let source =  to.fromProtocolVC  else {
                    transitionContext.completeTransition(true)
                    print("Need Implement PassViewFromProtocol")
                    return
            }

            config.playLayer?.clearURLWhenChangeView = false
            pass.translatesAutoresizingMaskIntoConstraints = true
            let superV = source.backReplaceSuperView?(original: config.passOriginalSuper) ?? config.passOriginalSuper
            let original:CGRect = pass.convert(pass.frame, to: nil)

            let convertRect:CGRect = (superV != nil ) ? superV!.convert(superV!.frame, to: nil) : .zero
            
            if superV != nil {
                pass.removeFromSuperview()
                container.addSubview(pass)
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
                config.playLayer?.clearURLWhenChangeView = true
                source.transitionCompleted()
            })
        default:
            break
        }
        
    }
}
