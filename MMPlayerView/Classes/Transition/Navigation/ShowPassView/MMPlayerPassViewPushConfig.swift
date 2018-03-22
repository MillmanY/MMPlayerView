//
//  PassViewPushConfig.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/22.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

public class MMPlayerPassViewPushConfig: NSObject ,MMPlayerNavConfig {
    
    weak public var passOriginalSuper: UIView?
    weak public var playLayer: MMPlayerLayer?
    public var duration:TimeInterval = 0.3
}
