//
//  MMPlayerMP4Converter.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/16.
//

import Foundation
import AVFoundation
@available(iOS 11.0, *)
class MMPlayerDownloadRequest {
    let asset: AVURLAsset
    fileprivate var timer: Timer?
    var statusBlock: ((_ status: MMPlayerDownloader.DownloadStatus)->Void)?
    let videoPath: (current: URL, hide: URL)
    let pathInfo: DownloaderPath
    let fileName: String
    
    let manager: MMPlayerHLSManager
    
    public init(url: URL, pathInfo: DownloaderPath, fileName: String?, manager: MMPlayerHLSManager) {
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
        DispatchQueue.main.async { [weak self] in
            if self?.asset.isExportable == true {
                self?.export()
            } else {
                self?.hls()
            }
        }
    }
    
    func hls() {
        manager.start(asset: asset, fileName: fileName) { [weak self] (status) in
            guard let self = self else {return}
            switch status {
            case .completed(let data):
                try? data.write(to: self.videoPath.current)
                let info = MMPlayerDownLoadVideoInfo(url: self.asset.url,
                                                     type: .hls,
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
    
    func export() {
        let downloadURL = self.asset.url
        let range = CMTimeRange(start: CMTime(value: 0, timescale: 1000), end: asset.duration)
        let composition = AVMutableComposition()
        do {
            try composition.insertTimeRange(range, of: asset, at: CMTime.zero)
        } catch {
            return
        }

        let finalComposition = composition.copy() as! AVComposition

        guard let export = AVAssetExportSession(asset: finalComposition, presetName: AVAssetExportPresetPassthrough) else {
            return
        }

        let path = self.videoPath.hide
        export.outputURL = path
        export.outputFileType = .mp4
        export.exportAsynchronously(completionHandler: { [unowned self] in
            switch export.status {
            case .exporting:
                break
            case .cancelled:
                self.timer?.invalidate()
                self.timer = nil
                try? FileManager.default.removeItem(at: self.videoPath.hide)
                self.statusBlock?(.cancelled)
            case .completed:
                self.timer?.invalidate()
                self.timer = nil
                try? FileManager.default.moveItem(at: self.videoPath.hide, to: self.videoPath.current.appendingPathExtension("mp4"))
                let info = MMPlayerDownLoadVideoInfo(url: downloadURL,
                                                     type: .mp4,
                                                     fileName: self.fileName,
                                                     fileSubPath: self.pathInfo.subPath)
                self.statusBlock?(.completed(info: info))
            case .failed:
                self.timer?.invalidate()
                self.timer = nil
                try? FileManager.default.removeItem(at: self.videoPath.hide)
                self.statusBlock?(.failed(err: export.error?.localizedDescription ?? "Unknown error"))
            case .unknown , .waiting:
                self.timer?.invalidate()
                self.timer = nil
                self.statusBlock?(.none)
            }
        })
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(progressUpdate), userInfo: export, repeats: true)
    }
    
    @objc func progressUpdate(timer: Timer) {
        if let export = timer.userInfo as? AVAssetExportSession {
            self.statusBlock?(.downloading(value: export.progress))
        }
    }
}
