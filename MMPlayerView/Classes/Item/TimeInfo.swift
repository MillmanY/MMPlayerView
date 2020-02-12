//
//  TimeInfo.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/9.
//

import Foundation
import AVFoundation
public struct TimeInfo {
    public let current: CMTime
    public let total: CMTime
    public var willEndTime: CMTime {
        get {
            return total - current
        }
    }
    init(current: CMTime = .zero, total: CMTime = .zero) {
        self.current = current.isNumeric ? current : .zero
        self.total = total.isNumeric ? total : .zero
    }
}
