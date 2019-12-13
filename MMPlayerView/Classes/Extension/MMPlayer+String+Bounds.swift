//
//  MMPlayer+String+Bounds.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/9.
//

import Foundation
extension String {
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    subscript (safe range: CountableClosedRange<Int>) -> String {
        if range.lowerBound < 0 || range.upperBound >= self.count {
            return ""
        }
        return self[range.lowerBound..<range.upperBound+1]
    }
    
    func get(index: Int) -> String.Index {
        return self.index(startIndex, offsetBy: index)
    }

    subscript (r: Range<Int>) -> String {
        let start = self.get(index: r.lowerBound)
        let end = self.get(index: r.upperBound)
        return String(self[start..<end])
    }
    func subStrings(_ value: String) -> [NSRange] {
        var range = [NSRange]()
        var index = 0
        while index <= self.count {
            let r = NSString(string: self[index..<self.count]).range(of: value)
            if r.length > 0 {
                range.append(NSRange.init(location: index+r.location, length: r.length))
                index += r.length+r.location
                
            } else {
                index += 1
            }
        }
        return range
    }
}
