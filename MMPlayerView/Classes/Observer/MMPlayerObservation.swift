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
        case invalidate
    }
    public var status: Status = .resume
    
    private func invalidate() {
        self.status = .invalidate
        self.invalidateBlock?()
        self.invalidateBlock = nil
    }
    
    deinit {
        self.invalidate()
    }
}

public class MMPlayerMapObserverManager<Key: Hashable, Observer>: NSObject {
    private var map = [Key: [(subscribe: Observer, observation: WeakBox<MMPlayerObservation>)]]()
    public subscript(key: Key) -> [Observer] {
        return map[key]?.compactMap({
            $0.observation.value?.status == .resume ? $0.subscribe : nil
        }) ?? [Observer]()
    }
    
    public func add(key: Key, observer: Observer) -> MMPlayerObservation {
        if map[key] == nil {
            map[key] = [(subscribe: Observer, observation: WeakBox<MMPlayerObservation>)]()
        }
        let observation = self.generateObservation(key: key)
        let appendValue = (observer, WeakBox(observation))
        map[key]?.append(appendValue)
        return observation
    }
    
    public func remove(key: Key) {
        self.map[key] = nil
    }
    
    private func generateObservation(key: Key) -> MMPlayerObservation {
        let observation = MMPlayerObservation()
        
        observation.invalidateBlock = { [weak self, weak observation] in
            self?.map[key]?.removeAll(where: { $0.observation.value == observation })
            if self?.map[key]?.count == 0 {
                self?.map[key] = nil
            }
        }
        return observation
    }
}


public class MMPlayerListObserverManager<Observer>: NSObject {
    var list = [(subscribe: Observer, observation: WeakBox<MMPlayerObservation>)]()
    
    public func append(observer: Observer) -> MMPlayerObservation {
        let observation = self.generateObservation()
        let appendValue = (observer, WeakBox(observation))
        self.list.append(appendValue)
        return observation
    }
    
    private func generateObservation() -> MMPlayerObservation {
        let observation = MMPlayerObservation()
        observation.invalidateBlock = { [weak self, weak observation] in
            self?.list.removeAll(where: { $0.observation.value == observation })
        }
        return observation
    }
}
