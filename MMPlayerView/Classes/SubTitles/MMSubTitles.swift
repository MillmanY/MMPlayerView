//
//  SubTitles.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/13.
//

import Foundation
public class MMSubTitles<C: ConverterProtocol> {
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

//
//        let value = Bundle.main.path(forResource: "test", ofType: "srt")!
//        if let str = try? String.init(contentsOfFile: value) {
//            srt.parseText(str)
//            srt.search(duration: 100.95, completed: { (info) in
//                print(info)
//            })
//
////
////            srt.search(duration: 200, completed: { (info) in
////                print(info)
////            })
//
//        }
//
