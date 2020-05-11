# MMPlayerView
[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=W5C6A3FB8H4DQ)

[![CI Status](http://img.shields.io/travis/millmanyang@gmail.com/MMPlayerView.svg?style=flat)](https://travis-ci.org/millmanyang@gmail.com/MMPlayerView)
[![Version](https://img.shields.io/cocoapods/v/MMPlayerView.svg?style=flat)](http://cocoapods.org/pods/MMPlayerView)
[![License](https://img.shields.io/cocoapods/l/MMPlayerView.svg?style=flat)](http://cocoapods.org/pods/MMPlayerView)
[![Platform](https://img.shields.io/cocoapods/p/MMPlayerView.svg?style=flat)](http://cocoapods.org/pods/MMPlayerView)
## Demo-Swift

## List / Shrink / Transition / Landscape
![list](https://github.com/MillmanY/MMPlayerView/blob/master/demo/list_demo.gif)
![shrink](https://github.com/MillmanY/MMPlayerView/blob/master/demo/shrink_demo.gif) 
![transition](https://github.com/MillmanY/MMPlayerView/blob/master/demo/transition_demo.gif)
![landscape](https://github.com/MillmanY/MMPlayerView/blob/master/demo/landscape_demo.gif)

## MMPlayerLayer       
    ex. use when change player view frequently like tableView / collectionView
    import MMPlayerView
    mmPlayerLayer.playView = cell.imgView
    mmPlayerLayer.getStatusBlock { [weak self] (status) in

    }
    self.mmPlayerLayer.set(url: DemoSource.shared.demoData[indexPath.row].play_Url)
    self.mmPlayerLayer.resume()

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

## Landscape
    1.Set MMPlayerLayer
       // roation screen to landscape can change player to fullscreen
       mmplayerLayer.fullScreenWhenLandscape = true
       
    2. Set from code
       mmplayerLayer.setOrientation(.landsacpeLeft)
       
    3. Observer
      mmPlayerLayer.getOrientationChange { (status) in
            print("Player OrientationChange \(status)")
      }
 
## Cover View
![landscape](https://github.com/MillmanY/MMPlayerView/blob/master/demo/cover.png)

    ## add cover item view on player
    play.replace(cover: CoverA.instantiateFromNib())

## Progress
    // Custom your progress view and it will add on player center
    // view need to implement ProgressProtocol, and add progress in this view, when start/stop control what need to do
    .custom(view: <#T##MMProgressProtocol#>)
     public protocol MMProgressProtocol {
         func start()
         func stop()
     }
     
## Cache
    playerLayer.cacheType = .memory(count: 10)
    public enum MMPlayerCacheType {
        case none
        case memory(count: Int) // set this to cache seek time in memory and if cache out of count will remove first you    
        stored
    }
## Layer Protocol
    // detect if touch in videoRect
    // if touch out of videoRect will not trigger show/hide cover view event
    public protocol MMPlayerLayerProtocol: class {
    
    func touchInVideoRect(contain: 
    
    ) // 
    }
 
## Downloader
            var downloadObservation: MMPlayerObservation?

            downloadObservation = MMPlayerDownloader.shared.observe(downloadURL: downloadURL) { [weak self] (status) in
                switch status {
                case .cancelled:
                    print("Canceld")
                case .completed:
                    DispatchQueue.main.async {
                        self?.downloadBtn.setTitle("Delete", for: .normal)
                        self?.downloadBtn.isHidden = false
                        self?.progress.isHidden = true
                    }
                case .downloading(let value):
                    self?.downloadBtn.isHidden = true
                    self?.progress.isHidden = false
                    self?.progress.progress = value
                    print("Exporting \(value) \(downloadURL)")
                case .failed(let err):
                    DispatchQueue.main.async {
                        self?.downloadBtn.setTitle("Download", for: .normal)
                    }
                    
                    self?.downloadBtn.isHidden = false
                    self?.progress.isHidden = true
                    print("Download Failed \(err)")
                case .none:
                    DispatchQueue.main.async {
                        self?.downloadBtn.setTitle("Download", for: .normal)
                    }
                    self?.downloadBtn.isHidden = false
                    self?.progress.isHidden = true
                case .exist:
                    DispatchQueue.main.async {
                        self?.downloadBtn.setTitle("Delete", for: .normal)
                    }
                    self?.downloadBtn.isHidden = false
                    self?.progress.isHidden = true
                }
## Delete
            if let info = MMPlayerDownloader.shared.localFileFrom(url: downloadURL)  {
                MMPlayerDownloader.shared.deleteVideo(info)
            }
## Subtitle
![](https://github.com/MillmanY/MMPlayerView/blob/master/demo/subTitleSmall.png)

         let subTitleStr = Bundle.main.path(forResource: "test", ofType: "srt")!
             if let str = try? String.init(contentsOfFile: subTitleStr) {
                 self.mmPlayerLayer.subtitleSetting.subtitleType = .srt(info: str)
                 self.mmPlayerLayer.subtitleSetting.defaultTextColor = .red
                 self.mmPlayerLayer.subtitleSetting.defaultFont = UIFont.boldSystemFont(ofSize: 20)
             }
         }
## Shrink
        // Return a view which you want back
        self.mmPlayerLayer.shrinkView(onVC: self, isHiddenVC: false) { [weak self] () -> UIView? in
            guard let self = self, let path = self.findCurrentPath() else {return nil}
            let cell = self.findCurrentCell(path: path) as! PlayerCell
            self.mmPlayerLayer.set(url: cell.data!.play_Url)
            self.mmPlayerLayer.resume()
            return cell.imgView
        }
        // Check player is shrink or not
        self.mmPlayerL.isShrink
## Demo-SwiftUI

### Control
    let control = MMPlayerControl()
    //Play
    control.set(url: self.videoList[idx].play_Url)
    control.resume()
    //InValidate
    control.invalidate()
    //Observation parameter
    @Published
    public var orientation: PlayerOrientation = .protrait
    @Published
    public var timeInfo = TimeInfo()
    @Published
    public var isMuted = false
    @Published
    public var isBackgroundPause = true
    @Published
    @Published
    public var repeatWhenEnd: Bool = false
    @Published
    public var isLoading: Bool = false
    public var cacheType: PlayerCacheType = .none
    @Published
    public private(set) var isCoverShow = false
    @Published
    public var autoHideCoverType = CoverAutoHideType.disable
    public var coverAnimationInterval = 0.3
    @Published
    public var error: MMPlayerViewUIError?
### Init View
    let player = MMPlayerViewUI(control: self.control, cover: CoverAUI())
### Download
    view.modifier(MMPlayerDownloaderModifier(url: obj.play_Url!, status: $downloadStatus))
### Transition Player
    //func playerTransition<Content: View>(view: Content, from: CGRect?) -> AnyTransition
    if showDetailIdx != nil {
        DetailView(obj: self.playListViewModel.videoList[showDetailIdx!], showDetailIdx: $showDetailIdx)
           .edgesIgnoringSafeArea(.all)
           .transition(.playerTransition(view: MMPlayerViewUI(control: control) ,from: fromFrame))
            .zIndex(1)
    }
    // Trigger transition
    withAnimation { 
          self.fromFrame = obj.frame
          self.showDetailIdx = offset
    }
## Requirements

    iOS 12.0+
    Swift 5.0+
    
## Installation

MMPlayerView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
Swift 5 
pod 'MMPlayerView'
```
## Author

millmanyang@gmail.com

## License

MMPlayerView is available under the MIT license. See the LICENSE file for more info.
