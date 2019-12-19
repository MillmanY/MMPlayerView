//
//  SRT.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/12.
//

import Foundation
class SRT: ConverterProtocol {
    private var completed: (([Element])->Void)?
    public typealias Element = SRTInfo
    private var queue = DispatchQueue(label: "SRTConverter")
    private var currentIdx: Int? = nil
    private var splitValue = [SRTInfo]()
    var info: String = ""

    var findObjs = [Element]() {
        didSet {
            if oldValue == findObjs { return }
            completed?(findObjs)
        }
    }
    
    public init() {}
    public func search(duration: TimeInterval, completed: @escaping (([Element]) -> Void)) {
        self.completed = completed
        queue.async { [weak self] in
            guard let self = self, let idx = self.currentIdx else { return }
            var a = [Element]()
            let isInscreas = idx < self.splitValue.count-1
            self.queueSearch(duration: duration, findIndex: idx, isIncrease: isInscreas, conformElements: &a)
        }
    }
        
    public func parseText(_ value: String) {
        findObjs.removeAll()
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
    
    private func queueSearch(duration: TimeInterval, findIndex: Int, isIncrease: Bool, conformElements: inout [Element]) {
        if currentIdx == nil {
            return
        }
        guard let obj = splitValue[safe: findIndex] else {
            return
        }
        switch duration {
        case obj.timeRange:
            if conformElements.count == 0 {
                self.currentIdx = findIndex
            }
            conformElements.append(obj)
            self.queueSearch(duration: duration, findIndex: isIncrease ? findIndex+1 : findIndex-1 , isIncrease: isIncrease, conformElements: &conformElements)
        case ...obj.timeRange.lowerBound:
            if isIncrease == true {
                self.findObjs = conformElements
                return
            }
            self.queueSearch(duration: duration, findIndex: findIndex-1, isIncrease: false, conformElements: &conformElements)
        case obj.timeRange.upperBound...:
            if isIncrease == false {
                self.findObjs = conformElements
                return
            }
            self.queueSearch(duration: duration, findIndex: findIndex+1, isIncrease: true, conformElements: &conformElements)
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
