//
//  UIView+Shadow.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/25.
//
//

import Foundation
extension UIView {
    func setShadow(offset:CGSize,opacity:Float) {
        
        self.layer.masksToBounds = false
        //        self.layer.cornerRadius = radius
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor = UIColor.black.withAlphaComponent(1.0).cgColor
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
