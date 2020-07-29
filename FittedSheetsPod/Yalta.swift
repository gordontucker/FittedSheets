// The MIT License (MIT)
//
// Copyright (c) 2017-2020 Alexander Grebenyuk (github.com/kean).
//
// July 2020 version, to update copy all code from https://raw.githubusercontent.com/kean/Align/master/Sources/Align.swift (leaving this header instead of the updated one)
// Make sure to remove all `public` from this class so we don't cause issues with anyone using this library in their own code already

#if os(iOS) || os(tvOS)
import UIKit

protocol LayoutItem { // `UIView`, `UILayoutGuide`
    var superview: UIView? { get }
}

extension UIView: LayoutItem {}
extension UILayoutGuide: LayoutItem {
    var superview: UIView? { owningView }
}
#elseif os(macOS)
import AppKit

protocol LayoutItem { // `NSView`, `NSLayoutGuide`
    var superview: NSView? { get }
}

extension NSView: LayoutItem {}
extension NSLayoutGuide: LayoutItem {
    var superview: NSView? { owningView }
}
#endif

extension LayoutItem { // Align methods are available via `LayoutAnchors`
    @nonobjc var anchors: LayoutAnchors<Self> { LayoutAnchors(base: self) }
}

// MARK: - LayoutAnchors

struct LayoutAnchors<Base> {
    let base: Base
}

extension LayoutAnchors where Base: LayoutItem {

    // MARK: Anchors

    var top: Anchor<AnchorType.Edge, AnchorAxis.Vertical> { Anchor(base, .top) }
    var bottom: Anchor<AnchorType.Edge, AnchorAxis.Vertical> { Anchor(base, .bottom) }
    var left: Anchor<AnchorType.Edge, AnchorAxis.Horizontal> { Anchor(base, .left) }
    var right: Anchor<AnchorType.Edge, AnchorAxis.Horizontal> { Anchor(base, .right) }
    var leading: Anchor<AnchorType.Edge, AnchorAxis.Horizontal> { Anchor(base, .leading) }
    var trailing: Anchor<AnchorType.Edge, AnchorAxis.Horizontal> { Anchor(base, .trailing) }

    var centerX: Anchor<AnchorType.Center, AnchorAxis.Horizontal> { Anchor(base, .centerX) }
    var centerY: Anchor<AnchorType.Center, AnchorAxis.Vertical> { Anchor(base, .centerY) }

    var firstBaseline: Anchor<AnchorType.Baseline, AnchorAxis.Vertical> { Anchor(base, .firstBaseline) }
    var lastBaseline: Anchor<AnchorType.Baseline, AnchorAxis.Vertical> { Anchor(base, .lastBaseline) }

    var width: Anchor<AnchorType.Dimension, AnchorAxis.Horizontal> { Anchor(base, .width) }
    var height: Anchor<AnchorType.Dimension, AnchorAxis.Vertical> { Anchor(base, .height) }

    // MARK: Anchor Collections

    var edges: AnchorCollectionEdges { AnchorCollectionEdges(item: base) }
    var center: AnchorCollectionCenter { AnchorCollectionCenter(x: centerX, y: centerY) }
    var size: AnchorCollectionSize { AnchorCollectionSize(width: width, height: height) }
}

// MARK: - Anchors

// phantom types
enum AnchorAxis {
    class Horizontal {}
    class Vertical {}
}

enum AnchorType {
    class Dimension {}
    class Alignment {}
    class Center: Alignment {}
    class Edge: Alignment {}
    class Baseline: Alignment {}
}

/// An anchor represents one of the view's layout attributes (e.g. `left`,
/// `centerX`, `width`, etc).
///
/// Instead of creating `NSLayoutConstraint` objects directly, start with a `UIView`,
/// `NSView`, or `UILayoutGuide` object you wish to constrain, and select one of
/// that object’s anchor properties. These properties correspond to the main
/// `NSLayoutConstraint.Attribute` values used in Auto Layout, and provide an
/// appropriate `Anchor` type for creating constraints to that attribute. For
/// example, `view.anchors.top` is represted by `Anchor<AnchorType.Edge, AnchorAxis.Vertical>`.
/// Use the anchor’s methods to construct your constraint.
///
/// - note: `UIView` does not provide anchor properties for the layout margin attributes.
/// Instead, the `layoutMarginsGuide` property provides a `UILayoutGuide` object that
/// represents these margins. Use the guide’s anchor properties to create your constraints.
///
/// When you create constraints using `Anchor` APIs, the constraints are activated
/// automatically and the target view has `translatesAutoresizingMaskIntoConstraints`
/// set to `false`. If you want to activate all the constraints at the same or
/// create them without activation, use `Constraints` type.
struct Anchor<Type, Axis> { // type and axis are phantom types
    let item: LayoutItem
    let attribute: NSLayoutConstraint.Attribute
    let offset: CGFloat
    let multiplier: CGFloat

    init(_ item: LayoutItem, _ attribute: NSLayoutConstraint.Attribute, offset: CGFloat = 0, multiplier: CGFloat = 1) {
        self.item = item; self.attribute = attribute; self.offset = offset; self.multiplier = multiplier
    }

    /// Returns a new anchor offset by a given amount.
    ///
    /// - note: Consider using a convenience operator instead: `view.anchors.top + 10`.
    func offsetting(by offset: CGFloat) -> Anchor {
        Anchor(item, attribute, offset: self.offset + offset, multiplier: self.multiplier)
    }

    /// Returns a new anchor with a given multiplier.
    ///
    /// - note: Consider using a convenience operator instead: `view.anchors.height * 2`.
    func multiplied(by multiplier: CGFloat) -> Anchor {
        Anchor(item, attribute, offset: self.offset * multiplier, multiplier: self.multiplier * multiplier)
    }
}

func + <Type, Axis>(anchor: Anchor<Type, Axis>, offset: CGFloat) -> Anchor<Type, Axis> {
    anchor.offsetting(by: offset)
}

func - <Type, Axis>(anchor: Anchor<Type, Axis>, offset: CGFloat) -> Anchor<Type, Axis> {
    anchor.offsetting(by: -offset)
}

func * <Type, Axis>(anchor: Anchor<Type, Axis>, multiplier: CGFloat) -> Anchor<Type, Axis> {
    anchor.multiplied(by: multiplier)
}

// MARK: - Anchors (AnchorType.Alignment)

extension Anchor where Type: AnchorType.Alignment {
    /// Adds a constraint that defines the anchors' attributes as equal to each other.
    @discardableResult func equal<Type: AnchorType.Alignment>(_ anchor: Anchor<Type, Axis>, constant: CGFloat = 0) -> NSLayoutConstraint {
        Constraints.add(self, anchor, constant: constant, relation: .equal)
    }

    @discardableResult func greaterThanOrEqual<Type: AnchorType.Alignment>(_ anchor: Anchor<Type, Axis>, constant: CGFloat = 0) -> NSLayoutConstraint {
        Constraints.add(self, anchor, constant: constant, relation: .greaterThanOrEqual)
    }

    @discardableResult func lessThanOrEqual<Type: AnchorType.Alignment>(_ anchor: Anchor<Type, Axis>, constant: CGFloat = 0) -> NSLayoutConstraint {
        Constraints.add(self, anchor, constant: constant, relation: .lessThanOrEqual)
    }
}

// MARK: - Anchors (AnchorType.Dimension)

extension Anchor where Type: AnchorType.Dimension {
    /// Adds a constraint that defines the anchors' attributes as equal to each other.
    @discardableResult func equal<Type: AnchorType.Dimension, Axis>(_ anchor: Anchor<Type, Axis>, constant: CGFloat = 0) -> NSLayoutConstraint {
        Constraints.add(self, anchor, constant: constant, relation: .equal)
    }

    @discardableResult func greaterThanOrEqual<Type: AnchorType.Dimension, Axis>(_ anchor: Anchor<Type, Axis>, constant: CGFloat = 0) -> NSLayoutConstraint {
        Constraints.add(self, anchor, constant: constant, relation: .greaterThanOrEqual)
    }

    @discardableResult func lessThanOrEqual<Type: AnchorType.Dimension, Axis>(_ anchor: Anchor<Type, Axis>, constant: CGFloat = 0) -> NSLayoutConstraint {
        Constraints.add(self, anchor, constant: constant, relation: .lessThanOrEqual)
    }
}

// MARK: - Anchors (AnchorType.Dimension)

extension Anchor where Type: AnchorType.Dimension {
    @discardableResult func equal(_ constant: CGFloat) -> NSLayoutConstraint {
        Constraints.add(item: item, attribute: attribute, relatedBy: .equal, constant: constant)
    }

    @discardableResult func greaterThanOrEqual(_ constant: CGFloat) -> NSLayoutConstraint {
        Constraints.add(item: item, attribute: attribute, relatedBy: .greaterThanOrEqual, constant: constant)
    }

    @discardableResult func lessThanOrEqual(_ constant: CGFloat) -> NSLayoutConstraint {
        Constraints.add(item: item, attribute: attribute, relatedBy: .lessThanOrEqual, constant: constant)
    }

    /// Clamps the dimension of a view to the given limiting range.
    @discardableResult func clamp(to limits: ClosedRange<CGFloat>) -> [NSLayoutConstraint] {
        [greaterThanOrEqual(limits.lowerBound), lessThanOrEqual(limits.upperBound)]
    }
}

// MARK: - Anchors (AnchorType.Edge)

extension Anchor where Type: AnchorType.Edge {
    /// Pins the edge to the respected edges of the given container.
    @discardableResult func pin(to container: LayoutItem? = nil, inset: CGFloat = 0) -> NSLayoutConstraint {
        let isInverted = [.trailing, .right, .bottom].contains(attribute)
        return Constraints.add(self, toItem: container ?? item.superview!, attribute: attribute, constant: (isInverted ? -inset : inset))
    }

    /// Adds spacing between the current anchors.
    @discardableResult func spacing<Type: AnchorType.Edge>(_ spacing: CGFloat, to anchor: Anchor<Type, Axis>, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let isInverted = (attribute == .bottom && anchor.attribute == .top) ||
            (attribute == .right && anchor.attribute == .left) ||
            (attribute == .trailing && anchor.attribute == .leading)
        return Constraints.add(self, anchor, constant: isInverted ? -spacing : spacing, relation: isInverted ? relation.inverted : relation)
    }
}

// MARK: - Anchors (AnchorType.Center)

extension Anchor where Type: AnchorType.Center {
    /// Aligns the axis with a superview axis.
    @discardableResult func align(offset: CGFloat = 0) -> NSLayoutConstraint {
        Constraints.add(self, toItem: item.superview!, attribute: attribute, constant: offset)
    }
}

// MARK: - AnchorCollectionEdges

struct Alignment {
    enum Horizontal {
        case fill, center, leading, trailing
    }
    enum Vertical {
        case fill, center, top, bottom
    }

    let horizontal: Horizontal
    let vertical: Vertical

    init(horizontal: Horizontal, vertical: Vertical) {
        (self.horizontal, self.vertical) = (horizontal, vertical)
    }

    static let fill = Alignment(horizontal: .fill, vertical: .fill)
    static let center = Alignment(horizontal: .center, vertical: .center)
    static let topLeading = Alignment(horizontal: .leading, vertical: .top)
    static let leading = Alignment(horizontal: .leading, vertical: .fill)
    static let bottomLeading = Alignment(horizontal: .leading, vertical: .bottom)
    static let bottom = Alignment(horizontal: .fill, vertical: .bottom)
    static let bottomTrailing = Alignment(horizontal: .trailing, vertical: .bottom)
    static let trailing = Alignment(horizontal: .trailing, vertical: .fill)
    static let topTrailing = Alignment(horizontal: .trailing, vertical: .top)
    static let top = Alignment(horizontal: .fill, vertical: .top)
}

struct AnchorCollectionEdges {
    let item: LayoutItem
    var isAbsolute = false

    // By default, edges use locale-specific `.leading` and `.trailing`
    func absolute() -> AnchorCollectionEdges {
        AnchorCollectionEdges(item: item, isAbsolute: true)
    }

    #if os(iOS) || os(tvOS)
    typealias Axis = NSLayoutConstraint.Axis
    #else
    typealias Axis = NSLayoutConstraint.Orientation
    #endif

    // MARK: Core API

    @discardableResult func equal(_ item2: LayoutItem, insets: EdgeInsets = .zero) -> [NSLayoutConstraint] {
        pin(to: item2, insets: insets)
    }

    @discardableResult func lessThanOrEqual(_ item2: LayoutItem, insets: EdgeInsets = .zero) -> [NSLayoutConstraint] {
        pin(to: item2, insets: insets, axis: nil, alignment: .center, isCenteringEnabled: false)
    }

    @discardableResult func equal(_ item2: LayoutItem, insets: CGFloat) -> [NSLayoutConstraint] {
        pin(to: item2, insets: EdgeInsets(top: insets, left: insets, bottom: insets, right: insets))
    }

    @discardableResult func lessThanOrEqual(_ item2: LayoutItem, insets: CGFloat) -> [NSLayoutConstraint] {
        pin(to: item2, insets: EdgeInsets(top: insets, left: insets, bottom: insets, right: insets), axis: nil, alignment: .center, isCenteringEnabled: false)
    }

    // MARK: Semantic API

    /// Pins the edges to the edges of the given item. By default, pins the edges
    /// to the superview.
    ///
    /// - parameter target: The target view, by default, uses the superview.
    /// - parameter insets: Insets the reciever's edges by the given insets.
    /// - parameter axis: If provided, creates constraints only along the given
    /// axis. For example, if you pass axis `.horizontal`, only the `.leading`,
    /// `.trailing` (and `.centerX` if needed) attributes are used. `nil` by default
    /// - parameter alignment: `.fill` by default, see `Alignment` for a list of
    /// the available options.
    @discardableResult func pin(to item2: LayoutItem? = nil, insets: CGFloat, axis: Axis? = nil, alignment: Alignment = .fill) -> [NSLayoutConstraint] {
        pin(to: item2, insets: EdgeInsets(top: insets, left: insets, bottom: insets, right: insets), axis: axis, alignment: alignment)
    }

    /// Pins the edges to the edges of the given item. By default, pins the edges
    /// to the superview.
    ///
    /// - parameter target: The target view, by default, uses the superview.
    /// - parameter insets: Insets the reciever's edges by the given insets.
    /// - parameter axis: If provided, creates constraints only along the given
    /// axis. For example, if you pass axis `.horizontal`, only the `.leading`,
    /// `.trailing` (and `.centerX` if needed) attributes are used. `nil` by default
    /// - parameter alignment: `.fill` by default, see `Alignment` for a list of
    /// the available options.
    @discardableResult func pin(to item2: LayoutItem? = nil, insets: EdgeInsets = .zero, axis: Axis? = nil, alignment: Alignment = .fill) -> [NSLayoutConstraint] {
        pin(to: item2, insets: insets, axis: axis, alignment: alignment, isCenteringEnabled: true)
    }

    private func pin(to item2: LayoutItem?, insets: EdgeInsets, axis: Axis?, alignment: Alignment, isCenteringEnabled: Bool) -> [NSLayoutConstraint] {
        let item2 = item2 ?? item.superview!
        let left: NSLayoutConstraint.Attribute = isAbsolute ? .left : .leading
        let right: NSLayoutConstraint.Attribute = isAbsolute ? .right : .trailing
        var constraints = [NSLayoutConstraint]()

        func constrain(attribute: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation, constant: CGFloat) {
            constraints.append(Constraints.add(item: item, attribute: attribute, relatedBy: relation, toItem: item2, attribute: attribute, multiplier: 1, constant: constant))
        }

        if axis == nil || axis == .horizontal {
            constrain(attribute: left, relation: alignment.horizontal == .fill || alignment.horizontal == .leading ? .equal : .greaterThanOrEqual, constant: insets.left)
            constrain(attribute: right, relation: alignment.horizontal == .fill || alignment.horizontal == .trailing ? .equal : .lessThanOrEqual, constant: -insets.right)
            if alignment.horizontal == .center && isCenteringEnabled {
                constrain(attribute: .centerX, relation: .equal, constant: 0)
            }
        }
        if axis == nil || axis == .vertical {
            constrain(attribute: .top, relation: alignment.vertical == .fill || alignment.vertical == .top ? .equal : .greaterThanOrEqual, constant: insets.top)
            constrain(attribute: .bottom, relation: alignment.vertical == .fill || alignment.vertical == .bottom ? .equal : .lessThanOrEqual, constant: -insets.bottom)
            if alignment.vertical == .center && isCenteringEnabled {
                constrain(attribute: .centerY, relation: .equal, constant: 0)
            }
        }
        return constraints
    }
}

// MARK: - AnchorCollectionCenter

struct AnchorCollectionCenter {
    let x: Anchor<AnchorType.Center, AnchorAxis.Horizontal>
    let y: Anchor<AnchorType.Center, AnchorAxis.Vertical>

    // MARK: Core API

    @discardableResult func equal<Item: LayoutItem>(_ item2: Item, offset: CGPoint = .zero) -> [NSLayoutConstraint] {
        [x.equal(item2.anchors.centerX, constant: offset.x), y.equal(item2.anchors.centerY, constant: offset.y)]
    }

    @discardableResult func greaterThanOrEqual<Item: LayoutItem>(_ item2: Item, offset: CGPoint = .zero) -> [NSLayoutConstraint] {
        [x.greaterThanOrEqual(item2.anchors.centerX, constant: offset.x), y.greaterThanOrEqual(item2.anchors.centerY, constant: offset.y)]
    }

    @discardableResult func lessThanOrEqual<Item: LayoutItem>(_ item2: Item, offset: CGPoint = .zero) -> [NSLayoutConstraint] {
        [x.lessThanOrEqual(item2.anchors.centerX, constant: offset.x), y.lessThanOrEqual(item2.anchors.centerY, constant: offset.y)]
    }

    // MARK: Semantic API

    /// Centers the view in the superview.
    @discardableResult func align() -> [NSLayoutConstraint] {
        [x.align(), y.align()]
    }

    /// Makes the axis equal to the other collection of axis.
    @discardableResult func align<Item: LayoutItem>(with item: Item) -> [NSLayoutConstraint] {
        [x.equal(item.anchors.centerX), y.equal(item.anchors.centerY)]
    }
}

// MARK: - AnchorCollectionSize

struct AnchorCollectionSize {
    let width: Anchor<AnchorType.Dimension, AnchorAxis.Horizontal>
    let height: Anchor<AnchorType.Dimension, AnchorAxis.Vertical>

    // MARK: Core API

    /// Set the size of item.
    @discardableResult func equal(_ size: CGSize) -> [NSLayoutConstraint] {
        [width.equal(size.width), height.equal(size.height)]
    }

    /// Set the size of item.
    @discardableResult func greaterThanOrEqul(_ size: CGSize) -> [NSLayoutConstraint] {
        [width.greaterThanOrEqual(size.width), height.greaterThanOrEqual(size.height)]
    }

    /// Set the size of item.
    @discardableResult func lessThanOrEqual(_ size: CGSize) -> [NSLayoutConstraint] {
        [width.lessThanOrEqual(size.width), height.lessThanOrEqual(size.height)]
    }

    /// Makes the size of the item equal to the size of the other item.
    @discardableResult func equal<Item: LayoutItem>(_ item: Item, insets: CGSize = .zero, multiplier: CGFloat = 1) -> [NSLayoutConstraint] {
        [width.equal(item.anchors.width * multiplier - insets.width), height.equal(item.anchors.height * multiplier - insets.height)]
    }

    @discardableResult func greaterThanOrEqual<Item: LayoutItem>(_ item: Item, insets: CGSize = .zero, multiplier: CGFloat = 1) -> [NSLayoutConstraint] {
        [width.greaterThanOrEqual(item.anchors.width * multiplier - insets.width), height.greaterThanOrEqual(item.anchors.height * multiplier - insets.height)]
    }

    @discardableResult func lessThanOrEqual<Item: LayoutItem>(_ item: Item, insets: CGSize = .zero, multiplier: CGFloat = 1) -> [NSLayoutConstraint] {
        [width.lessThanOrEqual(item.anchors.width * multiplier - insets.width), height.lessThanOrEqual(item.anchors.height * multiplier - insets.height)]
    }
}

// MARK: - Constraints

final class Constraints: Collection {
    typealias Element = NSLayoutConstraint
    typealias Index = Int

    subscript(position: Int) -> NSLayoutConstraint {
        get { constraints[position] }
    }
    var startIndex: Int { constraints.startIndex }
    var endIndex: Int { constraints.endIndex }
    func index(after i: Int) -> Int { i + 1 }

    /// Returns all of the created constraints.
    private(set) var constraints = [NSLayoutConstraint]()

    /// All of the constraints created in the given closure are automatically
    /// activated at the same time. This is more efficient then installing them
    /// one-be-one. More importantly, it allows to make changes to the constraints
    /// before they are installed (e.g. change `priority`).
    ///
    /// - parameter activate: Set to `false` to disable automatic activation of
    /// constraints.
    @discardableResult init(activate: Bool = true, _ closure: () -> Void) {
        Constraints.stack.append(self)
        closure() // create constraints
        Constraints.stack.removeLast()
        if activate { NSLayoutConstraint.activate(constraints) }
    }

    // MARK: Activate

    /// Activates each constraint in the reciever.
    func activate() {
        NSLayoutConstraint.activate(constraints)
    }

    /// Deactivates each constraint in the reciever.
    func deactivate() {
        NSLayoutConstraint.deactivate(constraints)
    }

    // MARK: Adding Constraints

    /// Creates and automatically installs a constraint.
    static func add(item item1: Any, attribute attr1: NSLayoutConstraint.Attribute, relatedBy relation: NSLayoutConstraint.Relation = .equal, toItem item2: Any? = nil, attribute attr2: NSLayoutConstraint.Attribute? = nil, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        precondition(Thread.isMainThread, "Align APIs can only be used from the main thread")
        #if os(iOS) || os(tvOS)
        (item1 as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        #elseif os(macOS)
        (item1 as? NSView)?.translatesAutoresizingMaskIntoConstraints = false
        #endif
        let constraint = NSLayoutConstraint(item: item1, attribute: attr1, relatedBy: relation, toItem: item2, attribute: attr2 ?? .notAnAttribute, multiplier: multiplier, constant: constant)
        install(constraint)
        return constraint
    }

    /// Creates and automatically installs a constraint between two anchors.
    static func add<T1, A1, T2, A2>(_ lhs: Anchor<T1, A1>, _ rhs: Anchor<T2, A2>, constant: CGFloat = 0, multiplier: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        add(item: lhs.item, attribute: lhs.attribute, relatedBy: relation, toItem: rhs.item, attribute: rhs.attribute, multiplier: (multiplier / lhs.multiplier) * rhs.multiplier, constant: constant - lhs.offset + rhs.offset)
    }

    /// Creates and automatically installs a constraint between an anchor and
    /// a given item.
    static func add<T1, A1>(_ lhs: Anchor<T1, A1>, toItem item2: Any?, attribute attr2: NSLayoutConstraint.Attribute?, constant: CGFloat = 0, multiplier: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        add(item: lhs.item, attribute: lhs.attribute, relatedBy: relation, toItem: item2, attribute: attr2, multiplier: multiplier / lhs.multiplier, constant: constant - lhs.offset)
    }

    private static var stack = [Constraints]() // this is what enabled constraint auto-installing

    private static func install(_ constraint: NSLayoutConstraint) {
        if let group = stack.last {
            group.constraints.append(constraint)
        } else {
            constraint.isActive = true
        }
    }
}

extension Constraints {
    @discardableResult convenience init<A: LayoutItem>(for a: A, _ closure: (LayoutAnchors<A>) -> Void) {
        self.init { closure(a.anchors) }
    }

    @discardableResult convenience init<A: LayoutItem, B: LayoutItem>(for a: A, _ b: B, _ closure: (LayoutAnchors<A>, LayoutAnchors<B>) -> Void) {
        self.init { closure(a.anchors, b.anchors) }
    }

    @discardableResult convenience init<A: LayoutItem, B: LayoutItem, C: LayoutItem>(for a: A, _ b: B, _ c: C, _ closure: (LayoutAnchors<A>, LayoutAnchors<B>, LayoutAnchors<C>) -> Void) {
        self.init { closure(a.anchors, b.anchors, c.anchors) }
    }

    @discardableResult convenience init<A: LayoutItem, B: LayoutItem, C: LayoutItem, D: LayoutItem>(for a: A, _ b: B, _ c: C, _ d: D, _ closure: (LayoutAnchors<A>, LayoutAnchors<B>, LayoutAnchors<C>, LayoutAnchors<D>) -> Void) {
        self.init { closure(a.anchors, b.anchors, c.anchors, d.anchors) }
    }
}

// MARK: - Misc

#if os(iOS) || os(tvOS)
typealias EdgeInsets = UIEdgeInsets
#elseif os(macOS)
typealias EdgeInsets = NSEdgeInsets

extension NSEdgeInsets {
    static let zero = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}
#endif

extension NSLayoutConstraint.Relation {
    var inverted: NSLayoutConstraint.Relation {
        switch self {
        case .greaterThanOrEqual: return .lessThanOrEqual
        case .lessThanOrEqual: return .greaterThanOrEqual
        case .equal: return self
        @unknown default: return self
        }
    }
}

extension EdgeInsets {
    func inset(for attribute: NSLayoutConstraint.Attribute, edge: Bool = false) -> CGFloat {
        switch attribute {
        case .top: return top; case .bottom: return edge ? -bottom : bottom
        case .left, .leading: return left
        case .right, .trailing: return edge ? -right : right
        default: return 0
        }
    }
}
