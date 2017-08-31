//
//  UIView+LayoutFit.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/31.
//
//

import UIKit

struct MMPlayerLayoutFit {
    unowned let base: UIView
    
    init(_ base: UIView) {
        self.base = base
    }
    
    func layoutFitSuper() {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        self.base.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self.base]))
        self.base.superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self.base]))
    }
}

protocol MMPlayerLayoutFitCompatible {
    var mPlayFit: MMPlayerLayoutFit { get set }
}

extension UIView: MMPlayerLayoutFitCompatible {
    var mPlayFit: MMPlayerLayoutFit {
        get {
            return MMPlayerLayoutFit(self)
        } set{}
    }
}
