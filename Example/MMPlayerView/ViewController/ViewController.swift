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
        l.coverFitType = .fitToPlayerView
        l.videoGravity = AVLayerVideoGravityResizeAspectFill
        l.autoLoadUrl = false
        l.replace(cover: CoverA.instantiateFromNib())
        return l
    }()
    @IBOutlet weak var playerCollect: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        playerCollect.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom:  200, right:0)
        DispatchQueue.main.async { [unowned self] in
            self.playerCollect.contentOffset = .zero
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil) { [unowned self] (_) in
            switch UIDevice.current.orientation {
            case .landscapeLeft , .landscapeRight:
                let full = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullScreenViewController") as! FullScreenViewController
                MMLandscapeWindow.shared.makeKey(root: full, playLayer: self.mmPlayerLayer) { [unowned self] in
                    self.resetPlay()
                }
            default: break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateCell(at indexPath: IndexPath) {
        if self.presentedViewController != nil {
            return
        }
        if let cell = playerCollect.cellForItem(at: indexPath) as? PlayerCell {
            // set url prepare to load
            mmPlayerLayer.set(url: cell.data?.play_Url, state: { (status) in
                
            })
            // this thumb use when transition start and your video dosent start
            mmPlayerLayer.thumbImageView.image = cell.imgView.image
            // set video where to play
            mmPlayerLayer.playView = cell.imgView
        }
    }

    func delayReload() {
        if self.presentedViewController != nil {
            return
        }
        // start loading video
        mmPlayerLayer.startLoading()
    }
    
    fileprivate func resetPlay() {

        if let play = mmPlayerLayer.playView, let superV = play.superview {
            NSLayoutConstraint.deactivate(play.constraints)
            superV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": play]))
            superV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": play]))
        }
    }
}

// This protocol use to pass playerLayer to second UIViewcontroller
extension ViewController: MMPlayerFromProtocol {
    // when use table or collection will reuse cell and original playview will error , replace correct one
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
    
    func presentedView(isShrinkVideo: Bool) {
        self.playerCollect.reloadData()
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let m = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return CGSize.init(width: m, height: m*0.75)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let p = CGPoint(x: playerCollect.frame.width/2, y: playerCollect.contentOffset.y + playerCollect.frame.width/2)
        if let path = playerCollect.indexPathForItem(at: p) {
            self.updateCell(at: path)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(delayReload), with: nil, afterDelay: 0.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [unowned self] in
            self.updateCell(at: indexPath)
            self.delayReload()
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                vc.data = DemoSource.shared.demoData[indexPath.row]
                self.present(vc, animated: true, completion: nil)
//                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
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


