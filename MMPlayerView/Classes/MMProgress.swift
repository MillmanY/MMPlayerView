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
    
    fileprivate var custom: (UIView & MMProgressProtocol)? {
        willSet {
            custom?.removeFromSuperview()
        } didSet {
            if let v = custom {
                self.addSubview(v)
                v.mPlayFit.centerWith(size: v.frame.size)
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
        defaultIndicator.mPlayFit.layoutFitSuper()
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
