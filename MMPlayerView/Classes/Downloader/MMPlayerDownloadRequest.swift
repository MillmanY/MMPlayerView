//
//  MMPlayerMP4Converter.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/16.
//

import Foundation
import AVFoundation
class MMPlayerDownloadRequest {
    let asset: AVURLAsset
    fileprivate var timer: Timer?
    var statusBlock: ((_ status: MMPlayerDownloader.DownloadStatus)->Void)?
    let videoPath: (current: URL, hide: URL)
    let pathInfo: DownloaderPath
    let fileName: String
    
    let manager: MMPlayerDownloadManager
    public init(url: URL, pathInfo: DownloaderPath, fileName: String?, manager: MMPlayerDownloadManager) {
        self.asset = AVURLAsset.init(url: url)
        self.pathInfo =  pathInfo
        self.fileName = fileName ?? ""
        
        let lastPath = fileName ?? url.absoluteString.base64
        self.videoPath = (pathInfo.fullPath.appendingPathComponent(lastPath),
                          pathInfo.fullPath.appendingPathComponent(".\(lastPath)"))
        self.manager = manager
    }
    
    func start(status:((_ status: MMPlayerDownloader.DownloadStatus)->Void)?) {
        try? FileManager.default.removeItem(at: self.videoPath.hide)
        try? FileManager.default.removeItem(at: self.videoPath.current)
        self.statusBlock = status
        self.statusBlock?(.downloadWillStart)
        self.donwload()
    }
    
    func donwload() {
        manager.start(asset: asset, fileName: fileName) { [weak self] (status) in
            
            guard let self = self else {return}
            switch status {
            case .completed(let data, let type):
                let path = type == .hls ? self.videoPath.current : self.videoPath.current.appendingPathExtension("mp4")
                try? data.write(to: path)
                let info = MMPlayerDownLoadVideoInfo(url: self.asset.url,
                                                     type: type,
                                                     fileName: self.fileName,
                                                     fileSubPath: self.pathInfo.subPath)
                self.statusBlock?(.completed(info: info))
            case .failed(let err):
                self.statusBlock?(.failed(err: err))
            case .downloading(let value):
                self.statusBlock?(.downloading(value: value))
            case .none:
                self.statusBlock?(.none)
            }
        }
    }
}
