//
//  MMProgress.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/23.
//
//

import UIKit

class MMProgress: UIView {
    var disable = false
    override var frame: CGRect {
        didSet {
            self.isHidden = frame.isEmpty
        }
    }
    
    fileprivate lazy var defaultIndicator = {
        return UIActivityIndicatorView()
    }()
    
    fileprivate var custom: MMProgressProtocol? {
        willSet {
          (custom as? UIView)?.removeFromSuperview()
        } didSet {
            if let v = custom as? UIView {
                self.addSubview(v)
            }
        }
    }
    
    func set(progress: ProgressType) {
        switch progress {
        case .default:
            custom = nil
            disable = false
        case .custom(let view):
            self.custom = view
            disable = false
        case .none:
            custom = nil
            disable = true
        }
        self.layoutIfNeeded()
    }
       
    convenience init() {
        self.init(frame: .zero)
        self.isUserInteractionEnabled = false
        self.setup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if let c = custom as? UIView {
            var f = c.frame
            f.origin.x = (self.frame.width - f.width)/2
            f.origin.y = (self.frame.height - f.height)/2
            c.frame = f
        } else {
            defaultIndicator.frame = self.bounds
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        defaultIndicator.activityIndicatorViewStyle = .whiteLarge
        self.addSubview(defaultIndicator)
    }
    
    func start() {
        if disable {
            return
        }
        if !self.frame.isEmpty {
            self.isHidden = false
        }

        if (custom != nil) {
            self.custom?.start()
        } else {
            defaultIndicator.startAnimating()
        }
    }
    
    func stop() {
        if disable {
            return
        }

        self.isHidden = true

        if (custom != nil) {
            self.custom?.stop()
        } else {
            defaultIndicator.stopAnimating()
        }
    }

}
