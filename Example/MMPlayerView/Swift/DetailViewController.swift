//
//  DetailViewController.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2017/8/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import MMPlayerView
import AVFoundation

class DetailViewController: UIViewController {
    var downloadObservation: MMPlayerObservation?
    var data: DataObj? {
        didSet {
            self.loadViewIfNeeded()
            if let d = data {
                self.title = d.title
                textView.text = d.content
            }
            self.addDownloadObservation()
        }
    }
    fileprivate var playerLayer: MMPlayerLayer?
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var progress: UIProgressView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.mmPlayerTransition.present.pass { (config) in
            config.duration = 0.3
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        progress.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false        
        self.addDownloadObservation()
        
    }
    
    fileprivate func addDownloadObservation() {
        
        guard let downloadURL = self.data?.play_Url else {
            return
        }
        downloadObservation = MMPlayerDownloader.shared.observe(downloadURL: downloadURL) { [weak self] (status) in
            DispatchQueue.main.async {
                self?.setWith(status: status)
            }
        }
    }
    
    func setWith(status: MMPlayerDownloader.DownloadStatus) {
        switch status {
        case .downloadWillStart:
            self.downloadBtn.isHidden = true
            self.progress.isHidden = false
            self.progress.progress = 0
        case .cancelled:
            print("Canceld")
        case .completed:
            self.downloadBtn.setTitle("Delete", for: .normal)
            self.downloadBtn.isHidden = false
            self.progress.isHidden = true
        case .downloading(let value):
            self.downloadBtn.isHidden = true
            self.progress.isHidden = false
            self.progress.progress = value
        case .failed(let err):
            self.downloadBtn.setTitle("Download", for: .normal)
            let alert = UIAlertController(title: err, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.downloadBtn.isHidden = false
            self.progress.isHidden = true
        case .none:
            self.downloadBtn.setTitle("Download", for: .normal)
            self.downloadBtn.isHidden = false
            self.progress.isHidden = true
        case .exist:
            self.downloadBtn.setTitle("Delete", for: .normal)
            self.downloadBtn.isHidden = false
            self.progress.isHidden = true
        }

    }
    
    @IBAction func shrinkVideoAction() {
        self.playerLayer?.shrinkView(onVC: self, isHiddenVC: true, completedToView: nil)
//        (self.presentationController as? MMPlayerPassViewPresentatinController)?.shrinkView()
    }

    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadAction() {
        guard let downloadURL = self.data?.play_Url else {
            return
        }
        if let info = MMPlayerDownloader.shared.localFileFrom(url: downloadURL)  {
            MMPlayerDownloader.shared.deleteVideo(info)
            let alert = UIAlertController(title: "Delete completed", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        DispatchQueue.main.async {
            MMPlayerDownloader.shared.download(asset: AVURLAsset(url: downloadURL))
        }
    }
    deinit {
        print("DetailViewController deinit")
    }
}

extension DetailViewController: MMPlayerToProtocol {
    
    func transitionCompleted(player: MMPlayerLayer) {
        self.playerLayer = player
    }

    var containerView: UIView {
        get {
            return playerContainer
        }
    }
}
