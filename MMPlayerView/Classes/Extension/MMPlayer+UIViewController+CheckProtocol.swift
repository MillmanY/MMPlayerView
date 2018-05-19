//
//  MMPlayer+UIViewController+CheckProtocol.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2018/3/21.
//

import Foundation

extension UIViewController {
    var fromProtocolVC: (MMPlayerFromProtocol & UIViewController)? {
        get {
            return UIViewController.findFromVCWithProtocol(vc: self)
        }
    }
    
    var toProtocolVC: (MMPlayerToProtocol & UIViewController)? {
        get {
            return UIViewController.findToVCWithProtocol(vc: self)
        }
    }
    
    static func findFromVCWithProtocol(vc: UIViewController) -> (MMPlayerFromProtocol & UIViewController)? {
        if let pass = vc as? MMPlayerFromProtocol & UIViewController , pass.willPassView?() ?? true {
            return pass
        } else {
            var find: (MMPlayerFromProtocol & UIViewController)?
            vc.childViewControllers.forEach { (vc) in
                if let f = UIViewController.findFromVCWithProtocol(vc: vc) {
                    find = f
                }
            }
            return find
        }
    }

    static func findToVCWithProtocol(vc: UIViewController) -> (MMPlayerToProtocol & UIViewController)? {
        
        if let pass = vc as? MMPlayerToProtocol & UIViewController {
            return pass
        } else {
            var find: (MMPlayerToProtocol & UIViewController)?
            vc.childViewControllers.forEach { (vc) in
                if let f = UIViewController.findToVCWithProtocol(vc: vc) {
                    find = f
                }
            }
            return find
        }
    }

}
