//
//  String+second.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2020/1/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
extension TimeInterval {
    func convertSecondString() -> String {
        let component =  Date.dateComponentFrom(second: self)
        if let hour = component.hour ,
            let min = component.minute ,
            let sec = component.second {
            
            let fix =  hour > 0 ? NSString(format: "%02d:", hour) : ""
            let a = NSString(format: "%@%02d:%02d", fix,min,sec) as String
            return a
        } else {
            return "-:-"
        }
    }
}
extension Date {
    static func dateComponentFrom(second: Double) -> DateComponents {
        let interval = TimeInterval(second)
        let date1 = Date()
        let date2 = Date(timeInterval: interval, since: date1)
        let c = NSCalendar.current
        
        var components = c.dateComponents([.year,.month,.day,.hour,.minute,.second,.weekday], from: date1, to: date2)
        components.calendar = c
        return components
    }
}
