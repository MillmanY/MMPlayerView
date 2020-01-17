//
//  MMPlayer+AVPlayItem+ConvertStatus.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/3.
//

import Foundation

import AVFoundation
extension AVPlayerItem {
    func convertStatus() -> PlayStatus {
        switch self.status {
        case .failed:
            let msg =  self.error?.localizedDescription ??  ""
            return .failed(err: msg)
        case .readyToPlay:
            return .ready
        case .unknown:
            return .unknown
        @unknown default:
            return .unknown
        }
    }
    
    func convertUIStatus() -> PlayUIStatus {
        switch self.status {
        case .failed:
            let msg =  self.error?.localizedDescription ??  ""
            return .failed(err: MMPlayerViewUIError.init(id: .loadFailed, desc: msg))
        case .readyToPlay:
            return .ready
        case .unknown:
            return .unknown
        @unknown default:
            return .unknown
        }
    }
}
