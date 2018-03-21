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
        } else if let first = vc.childViewControllers.first(where: { UIViewController.findFromVCWithProtocol(vc: $0) != nil }) as? MMPlayerFromProtocol & UIViewController {
            return first
        }
        return nil
    }

    static func findToVCWithProtocol(vc: UIViewController) -> (MMPlayerToProtocol & UIViewController)? {
        
        if let pass = vc as? MMPlayerToProtocol & UIViewController {
            return pass
        } else if let first = vc.childViewControllers.first(where: { UIViewController.findFromVCWithProtocol(vc: $0) != nil }) as? MMPlayerToProtocol & UIViewController {
            return first
        }
        return nil
    }

}
