//
//  SubTitles.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/13.
//

import Foundation
public class MMSubtitles<C: ConverterProtocol> {
    let converter: C
    
    public init(_ converter: C) {
        self.converter = converter
    }
    
    public func parseText(_ value: String) {
        converter.parseText(value)
    }
    
    public func search(duration: TimeInterval, completed: @escaping ((C.Element)->Void), queue: DispatchQueue?) {
        converter.search(duration: duration) { (e) in
            if let q = queue {
                q.async {
                    completed(e)
                }
            } else {
                completed(e)
            }
        }
    }
}
