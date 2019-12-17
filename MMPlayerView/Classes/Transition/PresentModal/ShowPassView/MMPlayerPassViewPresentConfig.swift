//
//  PassViewConfig.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/16.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import UIKit

public class MMPlayerPassViewPresentConfig: NSObject ,MMPlayerPresentConfig {

    weak public var passOriginalSuper: UIView?
    weak public var playLayer: MMPlayerLayer?
    public var margin: CGFloat = 10.0
    public var isMarginNeedArea = true
    public var duration:TimeInterval = 0.3
    weak public var source: UIViewController?
}
