//
//  BasePresentationController.swift
//  Pods
//
//  Created by Millman YANG on 2017/3/27.
//
//

import UIKit

public class MMPlayerBasePresentationController: UIPresentationController {
    internal var config: MMPlayerPresentConfig!
    public convenience init(presentedViewController: UIViewController, presenting
        presentingViewController: UIViewController? ,
                            config: MMPlayerPresentConfig) {
        
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.config = config
        
    }
    
    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
    }
    
    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
    }
    
    public override var shouldPresentInFullscreen: Bool {
        return false
    }
    
    public override var shouldRemovePresentersView: Bool {
        return false
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        coordinator.animate(alongsideTransition: { [weak self] (context) in
            // Prevent Scale error
            guard let self = self else {return}
            if let c = self.containerView {
                self.presentingViewController.view.transform = .identity
                self.presentingViewController.view.frame = c.bounds
            }
            self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
        }) { (context) in
        }
    }
}
