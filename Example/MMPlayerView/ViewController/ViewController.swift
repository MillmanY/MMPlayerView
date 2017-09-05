//
//  ViewController.swift
//  MMPlayerView
//
//  Created by millmanyang@gmail.com on 06/20/2017.
//  Copyright (c) 2017 millmanyang@gmail.com. All rights reserved.
//

import UIKit
import AVFoundation
import MMPlayerView

class ViewController: UIViewController {
    lazy var mmPlayerLayer: MMPlayerLayer = {
        let l = MMPlayerLayer()
        l.cacheType = .memory(count: 5)
        l.coverFitType = .fitToPlayerView
        l.videoGravity = AVLayerVideoGravityResizeAspectFill
        l.replace(cover: CoverA.instantiateFromNib())
        return l
    }()
    @IBOutlet weak var playerCollect: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        playerCollect.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
        playerCollect.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right:0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateByContentOffset()
            self.startLoading()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil) { [unowned self] (_) in
            self.landscapeAction()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    fileprivate func landscapeAction() {
        // just landscape when last result was finish
        if self.playerCollect.isDragging || self.playerCollect.isTracking || self.presentedViewController != nil {
            return
        }
        if UIDevice.current.orientation.isLandscape {
            let full = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullScreenViewController") as! FullScreenViewController
            MMLandscapeWindow.shared.makeKey(root: full, playLayer: self.mmPlayerLayer, completed: {
                print("landscape completed")
                //                    self.playerCollect.isScrollEnabled = true
            })
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            self.updateByContentOffset()
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(startLoading), with: nil, afterDelay: 0.3)
            
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// This protocol use to pass playerLayer to second UIViewcontroller
extension ViewController: MMPlayerPrsentFromProtocol {
    // when second controller pop or dismiss, this help to put player back to where you want
    // original was player last view ex. it will be nil because of this view on reuse view
    func backReplaceSuperView(original: UIView?) -> UIView? {
        return original
    }

    // add layer to temp view and pass to another controller
    var passPlayer: MMPlayerLayer {
        return self.mmPlayerLayer
    }
    // current playview is cell.image hide prevent ui error
    func transitionWillStart() {
        self.mmPlayerLayer.playView?.isHidden = true
    }
    // show cell.image
    func transitionCompleted() {
        self.mmPlayerLayer.playView?.isHidden = false
    }
    
    func dismissViewFromGesture() {
        mmPlayerLayer.thumbImageView.image = nil
        self.updateByContentOffset()
        self.startLoading()
    }
    
    func presentedView(isShrinkVideo: Bool) {
        self.playerCollect.visibleCells.forEach {
            if ($0 as? PlayerCell)?.imgView.isHidden == true && isShrinkVideo {
                ($0 as? PlayerCell)?.imgView.isHidden = false
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let m = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return CGSize.init(width: m, height: m*0.75)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [unowned self] in
            if self.presentedViewController != nil {
                self.playerCollect.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                self.updateDetail(at: indexPath)
            } else {
                self.presentDetail(at: indexPath)
            }
        }
    }
    
    fileprivate func updateByContentOffset() {
        let p = CGPoint(x: playerCollect.frame.width/2, y: playerCollect.contentOffset.y + playerCollect.frame.width/2)
        
        if let path = playerCollect.indexPathForItem(at: p),
            self.presentedViewController == nil {
            self.updateCell(at: path)
        }
    }
    
    fileprivate func updateDetail(at indexPath: IndexPath) {
        self.mmPlayerLayer.thumbImageView.image = DemoSource.shared.demoData[indexPath.row].image
        self.mmPlayerLayer.set(url: DemoSource.shared.demoData[indexPath.row].play_Url, state: { (status) in
            
        })
        self.mmPlayerLayer.startLoading()
    }
    
    fileprivate func presentDetail(at indexPath: IndexPath) {
        self.updateCell(at: indexPath)
        self.startLoading()
        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            vc.data = DemoSource.shared.demoData[indexPath.row]
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    fileprivate func updateCell(at indexPath: IndexPath) {
        if let cell = playerCollect.cellForItem(at: indexPath) as? PlayerCell {
            // this thumb use when transition start and your video dosent start
            mmPlayerLayer.thumbImageView.image = cell.imgView.image
            // set video where to play
            if !MMLandscapeWindow.shared.isKeyWindow {
                mmPlayerLayer.playView = cell.imgView
            }
            
            // set url prepare to load
            mmPlayerLayer.set(url: cell.data?.play_Url, state: { (status) in
                switch status {
                case .failed(let err):
                    let alert = UIAlertController(title: "err", message: err.description, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                case .ready:
                    print("Ready to Play")
                case .playing:
                    print("Playing")
                case .pause:
                    print("Pause")
                case .end:
                    print("End")
                default: break
                }
            })
        }
    }
    
    @objc fileprivate func startLoading() {
        if self.presentedViewController != nil {
            return
        }
        // start loading video
        mmPlayerLayer.startLoading()
        self.landscapeAction()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DemoSource.shared.demoData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCell", for: indexPath) as? PlayerCell {
            cell.data = DemoSource.shared.demoData[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
}


