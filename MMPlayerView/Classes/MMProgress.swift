//
//  MMProgress.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/23.
//
//

import UIKit

public class MMProgress: UIView, IndicatorProtocol {
    fileprivate var useDefulat = false
    fileprivate lazy var defaultIndicator = {
        return UIActivityIndicatorView()
    }()
   
    convenience init() {
        self.init(frame: .zero)
        self.isUserInteractionEnabled = false
        self.setup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if !useDefulat {
            return
        }
        defaultIndicator.frame = self.bounds
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    open func setup() {
        useDefulat = true
        defaultIndicator.activityIndicatorViewStyle = .whiteLarge
        self.addSubview(defaultIndicator)
    }
    
    open func start() {
        if !useDefulat  {
            return
        }
        self.isHidden = false
        defaultIndicator.startAnimating()
    }
    
    open func stop() {
        if !useDefulat  {
            return
        }
        self.isHidden = true
        defaultIndicator.stopAnimating()
    }

}
