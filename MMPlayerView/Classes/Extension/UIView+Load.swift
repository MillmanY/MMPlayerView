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

extension UIView {
    
    public func mmPlayerLayer() -> MMPlayerLayer? {
        return self.layer.sublayers?.first(where: {
            $0.isKind(of: MMPlayerLayer.classForCoder())
        }) as? MMPlayerLayer
    }

}
