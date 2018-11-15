//
//  MMPlayerDownloadRequest.swift
//  Pods
//
//  Created by Millman YANG on 2017/9/2.
//
//

import UIKit
import AVFoundation
class MMPlayerDownloadRequest: NSObject {
    unowned let asset: AVURLAsset

    fileprivate var timer: Timer?
    fileprivate var willDownloadToUrlMap = [AVAggregateAssetDownloadTask: URL]()
    lazy var downloadSession: AVAssetDownloadURLSession = {
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "Download-Identifier")
        return AVAssetDownloadURLSession.init(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
    }()
    var statusBlock: ((_ status: MMPlayerDownloadStatus)->Void)?
    let videoPath: (current: URL, hide: URL)
    let pathInfo: DownloaderPath
    let fileName: String

    public init(asset: AVURLAsset, pathInfo: DownloaderPath, fileName: String) {
        self.asset = asset
        self.pathInfo =  pathInfo
        self.fileName = fileName
        self.videoPath = (pathInfo.fullPath.appendingPathComponent(fileName),
                          pathInfo.fullPath.appendingPathComponent(".\(fileName)"))
    }
    
    func start(status:((_ status: MMPlayerDownloadStatus)->Void)?) {
        try? FileManager.default.removeItem(at: self.videoPath.hide)
        try? FileManager.default.removeItem(at: self.videoPath.current)
        self.statusBlock = status
        
        if self.asset.isExportable {
            self.export()
        } else {
            let preferredMediaSelection = asset.preferredMediaSelection
            
            let task = downloadSession.aggregateAssetDownloadTask(with: asset,
                                                                  mediaSelections: [preferredMediaSelection],
                                                                  assetTitle: fileName,
                                                                  assetArtworkData: nil,
                                                                  options:
                [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265_000])
            task?.resume()
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

        let path = self.pathInfo.fullPath.appendingPathComponent(".\(fileName)")
        export.outputURL = path
        export.outputFileType = .mp4
        export.exportAsynchronously(completionHandler: { [unowned self] in
            switch export.status {
            case .exporting:
                break
            case .waiting:
                self.statusBlock?(.waiting)
            case .cancelled:
                self.timer?.invalidate()
                self.timer = nil
                try? FileManager.default.removeItem(at: self.videoPath.hide)
                self.statusBlock?(.cancelled)
            case .completed:
                self.timer?.invalidate()
                self.timer = nil
                try? FileManager.default.moveItem(at: self.videoPath.hide, to: self.videoPath.current)
                
                let info = MMPlayerDownLoadVideoInfo(url: downloadURL,
                                                     type: .mp4,
                                                     fileName: self.fileName,
                                                     fileSubPath: self.pathInfo.subPath)
                self.statusBlock?(.completed(info: info))
            case .failed:
                self.timer?.invalidate()
                self.timer = nil
                try? FileManager.default.removeItem(at: self.videoPath.hide)
                self.statusBlock?(.failed(err: ""))
            case .unknown:
                self.timer?.invalidate()
                self.timer = nil
                self.statusBlock?(.unknown)
            }
        })
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(progressUpdate), userInfo: export, repeats: true)
    }

    @objc func progressUpdate(timer: Timer) {
        if let export = timer.userInfo as? AVAssetExportSession {
            self.statusBlock?(.exporting(value: export.progress))
        }
    }
}


extension MMPlayerDownloadRequest: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let task = task as? AVAggregateAssetDownloadTask else { return }
        if let err = error as NSError? {
            switch (err.domain, err.code) {
            case (NSURLErrorDomain, NSURLErrorCancelled):
                statusBlock?(.failed(err: err.localizedDescription))
            case (NSURLErrorDomain, NSURLErrorUnknown):
                fatalError("Downloading HLS streams is not supported in the simulator.")
            default:
                fatalError("An unexpected error occured \(err.domain)")
                
            }
        } else if willDownloadToUrlMap[task] == nil {
            task.resume()
        } else {
            guard let downloadURL = willDownloadToUrlMap.removeValue(forKey: task) else { return }
            do {
                let data = try downloadURL.bookmarkData()
                try? data.write(to: videoPath.current)
                let info = MMPlayerDownLoadVideoInfo(url: task.urlAsset.url,
                                                     type: .hls,
                                                     fileName: fileName,
                                                     fileSubPath: self.pathInfo.subPath)

                statusBlock?(.completed(info: info))
            } catch let dataErr {
                
                statusBlock?(.failed(err: dataErr.localizedDescription))
            }
        }
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                            willDownloadTo location: URL) {
        
        willDownloadToUrlMap[aggregateAssetDownloadTask] = location
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                            didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                            timeRangeExpectedToLoad: CMTimeRange, for mediaSelection: AVMediaSelection) {
   
        let percentComplete = loadedTimeRanges.reduce(0) { (rc, value) -> Float in
            let loadedTimeRange: CMTimeRange = value.timeRangeValue
            return rc + Float((loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds))
        }
        statusBlock?(.exporting(value: percentComplete))
    }
}
