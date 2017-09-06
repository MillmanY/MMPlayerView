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
    
    func centerWith(size: CGSize) {
        self.base.translatesAutoresizingMaskIntoConstraints = false
        let cons = [
        NSLayoutConstraint(item: self.base,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: self.base.superview,
                           attribute: .centerX,
                           multiplier: 1,
                           constant: 0.0),
        NSLayoutConstraint(item: self.base,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: self.base.superview,
                           attribute: .centerY,
                           multiplier: 1,
                           constant: 0.0),
        NSLayoutConstraint(item: self.base,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 0.0,
                           constant: size.width),
        NSLayoutConstraint(item: self.base,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 0.0,
                           constant: size.height)]
        self.base.superview?.addConstraints(cons)
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
