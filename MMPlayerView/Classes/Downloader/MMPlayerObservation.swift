//
//  MMPlayerObservation.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/16.
//

import UIKit

public class MMPlayerObservation: NSObject {
    var invalidateBlock: (()->Void)?
    public enum Status {
        case pause
        case resume
    }
    public var status: Status = .resume
    
    fileprivate func invalidate() {
        self.invalidateBlock?()
        self.invalidateBlock = nil
    }
    
    deinit {
        self.invalidate()
    }
}

public class MMPlayerMapObserverManager<Key: Hashable, Observer>: NSObject {

    private var map = [Key: [(subscribe: Observer, observation: Unmanaged<MMPlayerObservation>)]]()
    
    public subscript(key: Key) -> [Observer] {
        return map[key]?.compactMap({
            $0.observation.takeUnretainedValue().status == .resume ? $0.subscribe : nil
        }) ?? [Observer]()
    }
    
    public func add(key: Key, observer: Observer) -> MMPlayerObservation {
        if map[key] == nil {
            map[key] = [(subscribe: Observer, observation: Unmanaged<MMPlayerObservation>)]()
        }
        let observation = self.generateObservation(key: key)
        let appendValue = (observer, observation.unmanaged)
        map[key]?.append(appendValue)
        return observation
    }
    
    public func remove(key: Key) {
        self.map[key] = nil
    }
    
    fileprivate func generateObservation(key: Key) -> MMPlayerObservation {
        let observation = MMPlayerObservation()
        observation.invalidateBlock = { [weak self] in
            self?.map[key] = nil
        }
        return observation
    }
}


