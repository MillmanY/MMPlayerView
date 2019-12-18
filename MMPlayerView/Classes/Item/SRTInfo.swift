//
//  SRTInfo.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/13.
//

import Foundation
public struct SRTInfo: Equatable {
    public let index: Int
    public let timeRange: ClosedRange<TimeInterval>
    public let text: String
    
    static func emptyInfo() -> Self {
        return SRTInfo(index: -1, timeRange: 0...0, text: "")
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.index == rhs.index &&
                lhs.timeRange == rhs.timeRange &&
                lhs.text == rhs.text)
    }
}
