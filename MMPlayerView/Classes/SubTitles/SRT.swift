//
//  SRT.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/12.
//

import Foundation
public class SRTConverter: MMSubTitlesProtocol {
    private var completed: ((Element)->Void)?
    public typealias Element = SRTInfo
    
    private var queue = DispatchQueue(label: "SRTConverter")
    private var currentIdx: Int? = nil
    private var splitValue = [Int: SRTInfo]()
    var info: String = ""
    var currentObj: SRTInfo? {
        didSet {
            if let c = currentObj {
                completed?(c)
            }
        }
    }
    public init() {}
    public func search(duration: TimeInterval, completed: @escaping ((SRTInfo) -> Void)) {
        self.completed = completed
        queue.async { [weak self] in
            guard let idx = self?.currentIdx else { return }
            self?.queueSearch(duration: duration, findIndex: idx)
        }
    }
    
    private func queueSearch(duration: TimeInterval, findIndex: Int, isIncrease: Bool? = nil) {
        if let current = self.currentObj, current.timeRange.contains(duration) {
            self.currentObj = current
            return
        }
        
        guard let obj = self.splitValue[findIndex] else {
            return
        }
        switch duration {
        case obj.timeRange:
            self.currentObj = obj
            self.currentIdx = findIndex
        case ...obj.timeRange.lowerBound:
            if isIncrease == true { return }
            self.queueSearch(duration: duration, findIndex: findIndex-1, isIncrease: false)
        case obj.timeRange.upperBound...:
            if let i = isIncrease, i == false { return }
            self.queueSearch(duration: duration, findIndex: findIndex+1, isIncrease: true)
        default:
            break
        }
    }
    
    public func parseText(_ value: String) {
        currentObj = nil
        splitValue.removeAll()
        self.info = value
        queue.async { [weak self] in self?.parse() }
    }

    private func parse() {
        var index: String = ""
        var time: String = ""
        var title: String = ""
        var currentAdd = 0
        let split = info.components(separatedBy: CharacterSet(charactersIn: "\n\r\n")).filter { $0 != "" }
        split.enumerated().forEach { (offset, str) in
            if currentAdd == 2, let i = Int(index), (i+1 == Int(str) || offset == split.count-1) {
                if offset == split.count-1 { title += str }
                splitValue[i] = SRTInfo(index: i, timeRange: time.splitSRTTime, text: title)
                currentAdd = 0
                index = ""
                time = ""
                title = ""
                
                if currentIdx == nil {
                    self.currentIdx = i
                }
            }
            switch currentAdd {
            case 0:
                index += str
                currentAdd += 1
            case 1:
                time += str
                currentAdd += 1
            case 2:
                title += str
            default: break
            }
        }
    }
}
