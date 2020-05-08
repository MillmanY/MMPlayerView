//
//  MMPLayerDownloaderModifier.swift
//  MMPlayerView
//
//  Created by Millman on 2020/2/3.
//

import SwiftUI

@available(iOS 13.0.0, *)
public struct MMPlayerDownloaderModifier: ViewModifier {
    @ObservedObject var status: MMPlayerDownloaderModifierStatus
    public init(downloader: MMPlayerDownloader = MMPlayerDownloader.shared,
                url: URL,
                status: Binding<MMPlayerDownloader.DownloadStatus>) {
        self.status = MMPlayerDownloaderModifierStatus(downloader: downloader, url: url, status: status)
    }
    
    public func body(content: Content) -> some View {
        content
    }
}

@available(iOS 13.0.0, *)
class MMPlayerDownloaderModifierStatus: ObservableObject {
    var ob: MMPlayerObservation?
    @Binding var status: MMPlayerDownloader.DownloadStatus
    init(downloader: MMPlayerDownloader = MMPlayerDownloader.shared, url: URL, status: Binding<MMPlayerDownloader.DownloadStatus>) {
        self._status = status
        ob = downloader.observe(downloadURL: url) { [weak self] (s) in
            DispatchQueue.main.async {
                self?.status = s
            }
        }
    }
}
