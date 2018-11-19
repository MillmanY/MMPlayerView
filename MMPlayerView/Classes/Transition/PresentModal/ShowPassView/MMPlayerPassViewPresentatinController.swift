//
//  PassViewPresentatinController.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/17.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

public class MMPlayerPassViewPresentatinController: MMPlayerBasePresentationController {

    lazy var shrinkControl: MMPlayerShrinkControl = {
        let control = MMPlayerShrinkControl.init(containerView: self.containerView!, config: config)
        control.to = self.presentedViewController
        control.from = self.presentingViewController
        return control
    }()

    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        self.presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] (context) in
            self?.presentingViewController.view.transform = .identity
        }, completion: nil)
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        
        get {            
            return containerView?.frame ?? .zero
        } set {}
    }
    
    public func shrinkView() {
        shrinkControl.shrinkView()
    }
}


