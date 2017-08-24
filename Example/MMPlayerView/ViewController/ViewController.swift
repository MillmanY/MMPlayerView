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
        self.mmPlayerTransition.push.pass(setting: { (config) in
            config.duration = 0.3
        })
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
    
    func updateCell(at indexPath: IndexPath) {
        
        if let cell = playerCollect.cellForItem(at: indexPath) as? PlayerCell {
            mmPlayerLayer.set(url: cell.data?.play_Url, state: { (status) in
                
            })
            mmPlayerLayer.thumbImageView.image = cell.imgView.image
            mmPlayerLayer.playView = cell.imgView
        }
    }

    func delayReload() {
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

extension ViewController: MMPlayerFromProtocol {
    func backReplaceSuperView(original: UIView?) -> UIView? {
        return original
    }

    var passPlayer: MMPlayerLayer {
        return self.mmPlayerLayer
    }
    func completed() {
        
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let m = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return CGSize.init(width: m, height: m*0.75)
    }
    

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let p = CGPoint.init(x: playerCollect.frame.width/2, y: playerCollect.contentOffset.y + playerCollect.frame.width/2)
        if let path = playerCollect.indexPathForItem(at: p) {
            self.updateCell(at: path)
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(delayReload), with: nil, afterDelay: 0.2)

    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(delayReload), with: nil, afterDelay: 0.01)

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [unowned self] in
            self.updateCell(at: indexPath)
            self.delayReload()
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                vc.data = DemoSource.shared.demoData[indexPath.row]

                self.navigationController?.pushViewController(vc, animated: true)
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


