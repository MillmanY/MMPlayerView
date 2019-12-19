//
//  MMPlayerLayer+Constraint.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/13.
//

import Foundation
private var layoutHelperKey = "LayoutHelper+Key"
extension UIView {
    var mmLayout:LayoutHelper {
        get {
            if let n = objc_getAssociatedObject(self, &layoutHelperKey) as? LayoutHelper {
                return n
            } else {
                let d = LayoutHelper(self)
                objc_setAssociatedObject(self, &layoutHelperKey, d, .OBJC_ASSOCIATION_RETAIN)
                return d
            }
        }
    }
}

class LayoutHelper: NSObject {
    enum AxisType {
        case equal(constant: CGFloat)
        case greaterThanOrEqual(constant: CGFloat)
        case lessThanOrEqual(constant: CGFloat)
    }
    
    enum DimensionType {
        case equal(constant: CGFloat)
        case greaterThanOrEqual(constant: CGFloat)
        case lessThanOrEqual(constant: CGFloat)
        case equalTo(anchor: NSLayoutDimension, multiplier: CGFloat, constant: CGFloat)
        case greaterThanOrEqualTo(anchor: NSLayoutDimension, multiplier: CGFloat, constant: CGFloat)
        case lessThanOrEqualTo(anchor: NSLayoutDimension, multiplier: CGFloat, constant: CGFloat)
    }
    
    enum ConstraintType: String {
        case left
        case right
        case top
        case bottom
        case leading
        case trailing
        case width
        case height
        case centerX
        case centerY
        case firstBaseLine
        case lastBaseLine
    }
    private var constraint = [ConstraintType: NSLayoutConstraint]()
    unowned let view: UIView
    init(_ view: UIView) {
        self.view = view
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    subscript(type: ConstraintType) -> NSLayoutConstraint? {
        return constraint[type]
    }
    
    func delete(type: ConstraintType) {
        if let c = constraint[type] {
            c.isActive = false
            self.view.removeConstraint(c)
        }
    }
    
    func layoutFitSuper() {
        guard let superV = self.view.superview else {
            return
        }
        self.view.mmLayout.setLeading(anchor: superV.leadingAnchor, type: .equal(constant: 0))
            .setTrailing(anchor: superV.trailingAnchor, type: .equal(constant: 0))
            .setTop(anchor: superV.topAnchor, type: .equal(constant: 0))
            .setBottom(anchor: superV.bottomAnchor, type: .equal(constant: 0))
    }
    
    func centerWith(size: CGSize) {
        guard let superV = self.view.superview else {
            return
        }
        self.view.mmLayout
            .setWidth(type: .equal(constant: size.width))
            .setHeight(type: .equal(constant: size.height))
            .setCenterX(anchor: superV.centerXAnchor, type: .equal(constant: 0))
            .setCenterY(anchor: superV.centerYAnchor, type: .equal(constant: 0))
    }
    
    @discardableResult
    func setLeft(anchor: NSLayoutXAxisAnchor, type: AxisType) -> Self {
        self.delete(type: .left)
        let layout = self.xAxisAnchor(selfAnchor: self.view.leftAnchor, other: anchor, type: type)
        constraint[.left] = layout
        layout.isActive = true
        return self
    }
    @discardableResult
    func setRight(anchor: NSLayoutXAxisAnchor, type: AxisType) -> Self {
        self.delete(type: .right)
        let layout = self.xAxisAnchor(selfAnchor: self.view.rightAnchor, other: anchor, type: type)
        constraint[.right] = layout
        layout.isActive = true
        return self
    }
    @discardableResult
    func setLeading(anchor: NSLayoutXAxisAnchor, type: AxisType) -> Self {
        self.delete(type: .leading)
        let layout = self.xAxisAnchor(selfAnchor: self.view.leadingAnchor, other: anchor, type: type)
        constraint[.leading] = layout
        layout.isActive = true
        return self
    }
    @discardableResult
    func setTrailing(anchor: NSLayoutXAxisAnchor, type: AxisType) -> Self {
        self.delete(type: .trailing)
        let layout = self.xAxisAnchor(selfAnchor: self.view.trailingAnchor, other: anchor, type: type)
        constraint[.trailing] = layout
        layout.isActive = true
        return self
    }
    @discardableResult
    func setCenterX(anchor: NSLayoutXAxisAnchor, type: AxisType) -> Self {
        self.delete(type: .centerX)
        let layout = self.xAxisAnchor(selfAnchor: self.view.centerXAnchor, other: anchor, type: type)
        constraint[.centerX] = layout
        layout.isActive = true
        return self
    }
    @discardableResult
    func setTop(anchor: NSLayoutYAxisAnchor, type: AxisType) -> Self {
        self.delete(type: .top)
        let layout = self.yAxisAnchor(selfAnchor: self.view.topAnchor, other: anchor, type: type)
        constraint[.top] = layout
        layout.isActive = true
        return self
    }
    @discardableResult
    func setBottom(anchor: NSLayoutYAxisAnchor, type: AxisType) -> Self {
        self.delete(type: .bottom)
        let layout = self.yAxisAnchor(selfAnchor: self.view.bottomAnchor, other: anchor, type: type)
        constraint[.bottom] = layout
        layout.isActive = true
        return self
    }
    @discardableResult
    func setCenterY(anchor: NSLayoutYAxisAnchor, type: AxisType) -> Self {
        self.delete(type: .centerY)
        let layout = self.yAxisAnchor(selfAnchor: self.view.centerYAnchor, other: anchor, type: type)
        constraint[.centerY] = layout
        layout.isActive = true
        return self
    }
    @discardableResult
    func setWidth(type: DimensionType) -> Self {
        self.delete(type: .width)
        
        let layout = self.dimension(selfAnchor: self.view.widthAnchor, type: type)
        constraint[.width] = layout
        layout.isActive = true
        return self
    }
    @discardableResult
    func setHeight(type: DimensionType) -> Self {
        self.delete(type: .height)
        let layout = self.dimension(selfAnchor: self.view.heightAnchor, type: type)
        constraint[.height] = layout
        layout.isActive = true
        return self
    }
    
    func dimension(selfAnchor: NSLayoutDimension, type: DimensionType) -> NSLayoutConstraint {
        switch type {
        case .equal(let constant):
            return selfAnchor.constraint(equalToConstant: constant)
        case .greaterThanOrEqual(let constant):
            return selfAnchor.constraint(greaterThanOrEqualToConstant: constant)
        case .lessThanOrEqual(let constant):
            return selfAnchor.constraint(lessThanOrEqualToConstant: constant)
        case .equalTo(let anchor, let multiplier, let constant):
            return selfAnchor.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
        case .lessThanOrEqualTo(let anchor, let multiplier, let constant):
            return selfAnchor.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)

        case .greaterThanOrEqualTo(let anchor, let multiplier, let constant):
           return  selfAnchor.constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
        }
    }
    
    func yAxisAnchor(selfAnchor: NSLayoutYAxisAnchor ,other : NSLayoutYAxisAnchor, type: AxisType) -> NSLayoutConstraint {
        switch type {
        case .equal(let constant):
            return selfAnchor.constraint(equalTo: other, constant: constant)
        case .greaterThanOrEqual(let constant):
            return  selfAnchor.constraint(greaterThanOrEqualTo: other, constant: constant)
        case .lessThanOrEqual(let constant):
            return  selfAnchor.constraint(lessThanOrEqualTo: other, constant: constant)
        }
    }
    
    func xAxisAnchor(selfAnchor: NSLayoutXAxisAnchor ,other : NSLayoutXAxisAnchor, type: AxisType) -> NSLayoutConstraint {
        switch type {
        case .equal(let constant):
            return selfAnchor.constraint(equalTo: other, constant: constant)
        case .greaterThanOrEqual(let constant):
            return  selfAnchor.constraint(greaterThanOrEqualTo: other, constant: constant)
        case .lessThanOrEqual(let constant):
            return  selfAnchor.constraint(lessThanOrEqualTo: other, constant: constant)
        }
    }
}
