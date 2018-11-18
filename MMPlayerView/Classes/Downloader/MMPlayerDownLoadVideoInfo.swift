//
//  MMPlayerDownLoadVideoInfo.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/15.
//

import Foundation

public struct MMPlayerDownLoadVideoInfo: Codable, Equatable {
    public enum VideoType: Int, Codable {
        case mp4 = 0
        case hls
    }

    let url: URL
    let type: VideoType
    let fileName: String
    let fileSubPath: String
    
    var localURL: URL {
        get {
            return URL.init(fileURLWithPath: VideoBasePath)
                      .appendingPathComponent(fileSubPath)
                      .appendingPathComponent(convrtFileName)
        }
    }
    
    fileprivate var convrtFileName: String {
        get {
            var name = fileName.isEmpty ? url.absoluteString.base64 : fileName
            switch self.type {
            case .hls:
                break
            case .mp4:
                name += ".mp4"
            }
            
            return name
        }
    }
    
    public static func == (lhs: MMPlayerDownLoadVideoInfo, rhs: MMPlayerDownLoadVideoInfo) -> Bool {
        return lhs.url == rhs.url &&
               lhs.type == rhs.type &&
               lhs.fileName == rhs.fileName &&
               lhs.fileSubPath == rhs.fileSubPath
    }
}
