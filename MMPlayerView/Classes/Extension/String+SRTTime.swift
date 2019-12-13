//
//  String+SRTTime.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/9.
//

import Foundation
extension String {
    var timeToInterval: TimeInterval {
        let split = self.split(separator: ",")
        let count = split.count
        if count == 0 {
            return 0
        } else if count == 2 {
            let time = split[0]
            let hms = time.split(separator: ":")
            if hms.count == 3 {
                let h = (Double(String(hms[0])) ?? 0)*3600
                let m = (Double(String(hms[1])) ?? 0)*60
                let s = (Double(String(hms[2])) ?? 0)
                let mile = (Double(String(split[1])) ?? 0)/1000
                return h+m+s+mile
            }
        }
        return 0
    }

    var splitSRTTime: ClosedRange<TimeInterval> {
        let slice = self.components(separatedBy: CharacterSet.whitespaces)
        if slice.count == 3 {
            return slice[0].timeToInterval...slice[2].timeToInterval
        }
        return 0...0
    }
}
