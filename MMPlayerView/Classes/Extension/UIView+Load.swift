//
//  UIView+Load.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/22.
//
//

extension UIView {
    public class func instantiateFromNib<T: UIView>(viewType: T.Type) -> T {
        return Bundle.main.loadNibNamed(String(describing: viewType), owner: nil, options: nil)!.first as! T
    }
    
    public class func instantiateFromNib() -> Self {
        return instantiateFromNib(viewType: self)
    }
}

private var MMPlayerKey = "MMPlayerKey"
extension UIView {
    
    var havePlayer: Bool {
        set {
            objc_setAssociatedObject(self, &MMPlayerKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            if newValue {
                let f = self.frame
                self.frame = f
            }
        } get {
            if let key = objc_getAssociatedObject(self, &MMPlayerKey) as? Bool {
                return key
            } else {
                return false
            }
        }
    }
    
    public func mmPlayerLayer() -> MMPlayerLayer? {
        return self.layer.sublayers?.first(where: {
            $0.isKind(of: MMPlayerLayer.classForCoder())
        }) as? MMPlayerLayer
    }
}

extension UIView {
    func customSet(frame: CGRect) {
        self.customSet(frame: frame)
        
        if self.havePlayer {
            let p = self.mmPlayerLayer()
            p?.frame = self.bounds
            p?.thumbImageView.frame = self.bounds
            p?.updateCoverConstraint()
        }
    }
    
    func customSet(bounds: CGRect) {
        self.customSet(bounds: bounds)
        if self.havePlayer {
            let p = self.mmPlayerLayer()
            p?.frame = self.bounds
        }
    }
    
    static func replaceFrameVar() {
        self.replace(original: #selector(setter: UIView.frame), to: #selector(UILabel.customSet(frame:)))
        self.replace(original: #selector(setter: UIView.bounds), to: #selector(UILabel.customSet(bounds:)))
    }

}
