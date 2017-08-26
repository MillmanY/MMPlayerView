# MMPlayerView

[![CI Status](http://img.shields.io/travis/millmanyang@gmail.com/MMPlayerView.svg?style=flat)](https://travis-ci.org/millmanyang@gmail.com/MMPlayerView)
[![Version](https://img.shields.io/cocoapods/v/MMPlayerView.svg?style=flat)](http://cocoapods.org/pods/MMPlayerView)
[![License](https://img.shields.io/cocoapods/l/MMPlayerView.svg?style=flat)](http://cocoapods.org/pods/MMPlayerView)
[![Platform](https://img.shields.io/cocoapods/p/MMPlayerView.svg?style=flat)](http://cocoapods.org/pods/MMPlayerView)
## Demo

## List / Shrink / Transition / Landscape
![list](https://github.com/MillmanY/MMPlayerView/blob/master/demo/list_demo.gif)
![shrink](https://github.com/MillmanY/MMPlayerView/blob/master/demo/shrink_demo.gif) 
![transition](https://github.com/MillmanY/MMPlayerView/blob/master/demo/transition_demo.gif)
![landscape](https://github.com/MillmanY/MMPlayerView/blob/master/demo/landscape_demo.gif)

## MMPlayerLayer 
    1. Parameter
         public enum CoverViewFitType {
            case fitToPlayerView // coverview fit with playerview
            case fitToVideoRect // fit with VideoRect
         }
         
         public enum ProgressType {
          case `default` // Use defualt indicator
          case none // disable indicator
          case custom(view: MMProgress) // Custom your Progress
        }
        public var progressType: MMPlayerView.ProgressType  
        public var coverFitType: MMPlayerView.CoverViewFitType
        public var changeViewClearPlayer: Bool // rest url will 
        public var hideCoverDuration: TimeInterval // auto hide cover view after duration
        lazy public var thumbImageView: UIImageView 
        public var playView: UIView?
        public var coverView: UIView? { get }
        public var autoLoadUrl: Bool // when call set(url:,state) to auto fecth video
        public var autoPlay: Bool // when MMPlayerView.PlayViewPlayStatus == ready auto play video
        public var currentPlayStatus: MMPlayerView.PlayViewPlayStatus 
        public var cacheInMemory: Bool // its AVPlayerItem cache in memory
        public var asset: AVURLAsset?
        public var playUrl: URL?
        public func setCoverView(enable: Bool)
        public func delayHideCover()
        public func replace(cover: UIView)
        public func set(url: URL?, state: ((MMPlayerView.PlayViewPlayStatus) -> Swift.Void)?)
        public func startLoading() // if autoLoadUrl = false your need call startLoading() yourself
    
    2. Quick Start
      
        ex. use when change player view frequently like tableView / collectionView
        import MMPlayerView
        mmPlayerLayer.playView = cell.imgView
        mmPlayerLayer.set(url: cell.data?.play_Url, state: { (status) in 
        })
## MMPlayerView
    let url = URL.init(string: "http://www.html5videoplayer.net/videos/toystory.mp4")!
    playView.replace(cover: CoverA.instantiateFromNib())
    playView.set(url: url, thumbImage: #imageLiteral(resourceName: "seven")) { (status) in
        switch status {
           case ....
        }
    }
    
## Transition
    
    ##PresentedViewController
    1. Set transition config
        required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
            self.mmPlayerTransition.present.pass { (config) in
                // setting
                .....
            }
        }
    2. Set MMPLayerToProtocol on PresentedViewController
    3. Set MMPlayerPrsentFromProtocol on PresentingViewController

## Shrink
    ex. only set present transition can use shrink video
    (self.presentationController as? PassViewPresentatinController)?.shrinkView()
## Landscape
    1.Set AppDelegate
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) ->        
        UIInterfaceOrientationMask {
        if window == MMLandscapeWindow.shared {
            return .allButUpsideDown
        } else {
            return ....
        }
     }
    2. Observer orientation when landscape call function
        MMLandscapeWindow.shared.makeKey(root: full, playLayer: self.mmPlayerLayer, completed: {
        })
## Cover View
![landscape](https://github.com/MillmanY/MMPlayerView/blob/master/demo/cover.png)

    ## add cover item view on player
    play.replace(cover: CoverA.instantiateFromNib())

## Requirements

    iOS 8.0+
    Xcode 8.0+
    Swift 3.0+
    
## Installation

MMPlayerView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MMPlayerView"
```

## Author

millmanyang@gmail.com, millmanyang@gmail.com

## License

MMPlayerView is available under the MIT license. See the LICENSE file for more info.
