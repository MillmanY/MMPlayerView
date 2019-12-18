//
//  SRT.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/12.
//

import Foundation
class SRT: ConverterProtocol {
    private var completed: ((Element)->Void)?
    public typealias Element = SRTInfo
    private var queue = DispatchQueue(label: "SRTConverter")
    private var currentIdx: Int? = nil
    private var splitValue = [SRTInfo]()
    var info: String = ""
    var currentObj: SRTInfo? {
        didSet {
            if oldValue == currentObj { return }
            completed?(currentObj ?? SRTInfo.emptyInfo())
        }
    }
    public init() {}
    public func search(duration: TimeInterval, completed: @escaping ((Element) -> Void)) {
        self.completed = completed
        queue.async { [weak self] in
            guard let idx = self?.currentIdx else { return }
            self?.queueSearch(duration: duration, findIndex: idx)
        }
    }
        
    public func parseText(_ value: String) {
        currentObj = nil
        splitValue.removeAll()
        self.info = value
        queue.async { [weak self] in self?.parse() }
    }
}

//Private
extension SRT {
    private func parse() {
        splitValue = self.convertInfoToSRT(info: self.info)
        currentIdx = splitValue.count > 0 ? 0 : nil
    }
    
    private func queueSearch(duration: TimeInterval, findIndex: Int, isIncrease: Bool? = nil) {
        if currentIdx != nil, let current = self.currentObj, current.timeRange.contains(duration) {
            return
        }
        guard let obj = splitValue[safe: findIndex] else {
            self.currentObj = nil
            return
        }
        switch duration {
        case obj.timeRange:
            self.currentObj = obj
            self.currentIdx = findIndex
        case ...obj.timeRange.lowerBound:
            if isIncrease == true {
                self.currentObj = nil
                return
            }
            self.queueSearch(duration: duration, findIndex: findIndex-1, isIncrease: false)
        case obj.timeRange.upperBound...:
            if let i = isIncrease, i == false {
                self.currentObj = nil
                return
            }
            self.queueSearch(duration: duration, findIndex: findIndex+1, isIncrease: true)
        default:
            break
        }
    }

    private func convertInfoToSRT(info: String) -> [SRTInfo] {
        var preRN = false
        return info.split { (c) -> Bool in
            if preRN && c == "\r\n" {
                preRN = false
                return true
            } else if c == "\r\n" {
                preRN = true
            } else {
                preRN = false
            }
            return false
        }.compactMap {
            var split = $0.split(separator: "\r\n")
            guard split.count >= 3, let index = Int(String(split.removeFirst())) else {
                return nil
            }
            let time = String(split.removeFirst())
            let text = split.joined(separator: "\r\n")
            return SRTInfo(index: index, timeRange: time.splitSRTTime, text: text)
        }
    }
}
