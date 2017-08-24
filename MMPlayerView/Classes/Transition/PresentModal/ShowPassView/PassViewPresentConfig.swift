//
//  PassViewConfig.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/16.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

public class PassViewPresentConfig: NSObject ,PresentConfig {
    weak var passOriginalSuper: UIView?
    weak var pass: UIView?
    public var duration:TimeInterval = 0.3
    public func addPass(playerLayer: MMPlayerLayer) {
        
    }
}
