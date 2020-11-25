//
// Interval.swift
//
// © 2020 Wolf McNally
// https://wolfmcnally.com
// MIT License
//

///
/// Interval-Formation Operator
///
infix operator .. : RangeFormationPrecedence

/// Operator to create a closed floating-point interval. The first number may
/// be greater than the second.
///
/// - Parameter left: The first bound. May be greater than the second bound.
/// - Parameter right: The second bound.
///
/// # Example #
/// ```
/// let i = 0..100
/// let j = 100..3.14
/// ```
@inlinable public func .. <T>(left: T, right: T) -> Interval<T> {
    Interval(left, right)
}

/// Represents a closed floating-point interval from `a..b`.
/// Unlike `ClosedRange`, `a` may be greater than `b`.
@frozen
public struct Interval<T: FloatingPoint> : Equatable, Hashable {
    public typealias Bound = T

    /// This interval's first bound.
    public let a: Bound
    /// This interval's second bound.
    public let b: Bound

    /// Creates a closed interval from `a..b`. `a` may be greater than `b`.
    ///
    /// - Parameter a: The first bound. May be greater than the second bound.
    /// - Parameter b: The second bound.
    ///
    /// # Example #
    /// ```
    /// let i = Interval(0, 100) // equivalent to 0..100
    /// let j = Interval(100, 3.14) // equivalent to 100..3.14
    /// ```
    @inlinable public init(_ a: Bound, _ b: Bound) {
        self.a = a
        self.b = b
    }

    /// Returns the unit interval.
    @inlinable public static var unit: Interval<T> { 0..1 }
}

extension Interval {
    /// Returns `true` if `a` is less than `b`, and `false` otherwise.
    ///
    /// # Example #
    /// ```
    /// (0..100).isAscending // true
    /// (100..0).isAscending // false
    /// ```
    @inlinable public var isAscending: Bool {
        a < b
    }

    /// Returns `true` if `a` is greater than `b`, and `false` otherwise.
    ///
    /// # Example #
    /// ```
    /// (0..100).isDescending // false
    /// (100..0).isDescending // true
    /// ```
    @inlinable public var isDescending: Bool {
        a > b
    }

    /// Returns `true` if `a` is equal to `b`, and `false` otherwise.
    /// Unlike `ClosedRange`, which always returns `false` from `isEmpty`,
    /// this attribute returns `true` if the two bounds are equal; that is,
    /// if the interval subtends no geometric space on the number line.
    ///
    /// # Example #
    /// ```
    /// (0..100).isEmpty // false
    /// (100..100).isEmpty // true
    /// ```
    @inlinable public var isEmpty: Bool {
        a == b
    }
}

extension Interval {
    /// Returns an interval with the same bounds as this interval, but reversed
    ///
    /// # Example #
    /// ```
    /// (0..100).reversed == 100..0 // true
    /// ```
    @inlinable public var reversed: Interval {
        Interval(b, a)
    }

    /// Returns an interval with the same bounds as this interval, but where `a` is the minimum bound and `b` is the maximum bound.
    ///
    /// # Example #
    /// ```
    /// (0..100).normalized == 0..100 // true
    /// (100..0).normalized == 0..100 // true
    /// ```
    @inlinable public var normalized: Interval {
        isAscending ? self : reversed
    }
}

extension Interval {
    /// Returns the lesser of the two bounds
    ///
    /// # Example #
    /// ```
    /// (0..100).min // 0.0
    /// ```
    @inlinable public var min: Bound {
        Swift.min(a, b)
    }

    /// Returns the greater of the two bounds
    ///
    /// # Example #
    /// ```
    /// (0..100).max // 100.0
    /// ```
    @inlinable public var max: Bound {
        Swift.max(a, b)
    }

    /// Returns the distance from `a` to `b`. If `b` > `a`, this value will be positive.
    ///
    /// # Example #
    /// ```
    /// (0..100).extent // 100.0
    /// (100..0).extent // -100.0
    /// ```
    @inlinable public var extent: T {
        b - a
    }

    /// Returns `true` if the interval contains the value `n`, otherwise returns `false`.
    ///
    /// - Parameter n: The value to test for containment within this interval.
    ///
    /// # Example #
    /// ```
    /// (0..100).contains(0) // true
    /// (0..100).contains(50) // true
    /// (0..100).contains(100) // true
    /// (0..100).contains(200) // false
    /// ```
    @inlinable public func contains(_ n: Bound) -> Bool {
        min <= n && n <= max
    }

    /// Returns `true` if the interval fully contains the `other` interval.
    ///
    /// - Parameter other: The interval to test for containment within this interval.
    ///
    /// # Example #
    /// ```
    /// (0..100).contains(1..10) // true
    /// (0..100).contains(10..1) // true
    /// (0..100).contains(-5..10) // false
    /// (0..100).contains(90..100) // true
    /// (0..100).contains(200..101) // false
    /// ```
    @inlinable public func contains(_ other: Interval) -> Bool {
        min <= other.min && other.max <= max
    }

    /// Returns `true` if the interval intersects with the `other` interval.
    ///
    /// - Parameter other: The interval to test for intersection with this interval.
    ///
    /// # Example #
    /// ```
    /// (0..100).intersects(with: 1..10) // true
    /// (0..100).intersects(with: 10..1) // true
    /// (0..100).intersects(with: -5..10) // true
    /// (0..100).intersects(with: 90..100) // true
    /// (0..100).intersects(with: 200..101) // false
    /// ```
    @inlinable public func intersects(with other: Interval) -> Bool {
        let i1 = self.normalized
        let i2 = other.normalized

        let isDisjoint = i2.b < i1.a || i1.b < i2.a
        return !isDisjoint
    }

    /// Returns the interval that is the intersection of this interval with the `other` interval.
    /// If the intervals do not intersect, return `nil`.
    ///
    /// - Parameter other: The interval to intersect with this interval.
    ///
    /// # Example #
    /// ```
    /// (0..60).intersection(with: (40..100)) // 40.0..60.0
    /// (60..0).intersection(with: (40..100)) // 40.0..60.0
    /// (0..50).intersection(with: (50..100)) // 50.0..50.0
    /// (0..30).intersection(with: (50..100)) // nil
    /// ```
    @inlinable public func intersection(with other: Interval) -> Interval? {
        let i1 = self.normalized
        let i2 = other.normalized

        let isDisjoint = i2.b < i1.a || i1.b < i2.a
        guard !isDisjoint else { return nil }

        return Interval(Swift.max(i1.a, i2.a), Swift.min(i1.b, i2.b))
    }

    /// Returns an interval with `a` being the least bound of the two intervals,
    /// and `b` being the greatest bound of the two intervals.
    ///
    /// - Parameter other: The interval to union with this interval.
    ///
    /// # Example #
    /// ```
    /// (0..40).union(with: (60..100)) // 0.0..100.0
    /// (0 .. -60).union(with: (40..100)) // -60.0..100.0
    /// (0..50).union(with: (50..100)) // 0.0..100.0
    /// (70..60).union(with: (50..100)) // 50.0..100.0
    /// ```
    @inlinable public func union(with other: Interval) -> Interval {
        Interval(Swift.min(min, other.min), Swift.max(max, other.max))
    }
}

extension Interval: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Interval(\(a)..\(b))"
    }
}

extension Interval: CustomStringConvertible {
    public var description: String {
        "\(a)..\(b)"
    }
}

extension Interval {
    /// Constructs an `Interval` from a `ClosedRange`.
    ///
    /// # Example #
    /// ```
    /// Interval(10.5...203.7) // 10.5..203.7
    /// ```
    @inlinable public init(_ r: ClosedRange<Bound>) {
        self.a = r.lowerBound
        self.b = r.upperBound
    }
}

extension ClosedRange where Bound: FloatingPoint {
    /// Constructs a `ClosedRange` from an `Interval`.
    /// If `a` > `b` then `b` will be the range's `lowerBound`.
    ///
    /// # Example #
    /// ```
    /// ClosedRange(10.5..203.7) // 10.5...203.7
    /// ClosedRange(203.7..10.5) // 10.5...203.7
    /// ```
    @inlinable public init(_ i: Interval<Bound>) {
        let i = i.normalized
        self.init(uncheckedBounds: (i.a, i.b))
    }
}

extension Interval {
    /// Returns `true` if `a` and `b` are both finite.
    @inlinable public var isFinite: Bool {
        a.isFinite && b.isFinite
    }
}

extension FloatingPoint {
    /// The value linearly interpolated from the unit interval `0..1` to the interval `a..b`.
    ///
    /// # Example #
    /// ```
    /// (0.5).interpolated(to: 20..30) // 25
    /// ```
    public func interpolated(to i: Interval<Self>) -> Self {
        assert(isFinite)
        assert(i.isFinite)
        return self * (i.b - i.a) + i.a
    }

    /// The value linearly interpolated from the interval `a..b` into the unit interval `0..1`.
    ///
    /// # Example #
    /// ```
    /// (25.0).interpolated(from: 20..30) // 0.5
    /// ```
    public func interpolated(from i: Interval<Self>) -> Self {
        assert(isFinite)
        assert(i.isFinite)
        assert(!i.isEmpty)
        return (i.a - self) / (i.a - i.b)
    }

    /// The value linearly interpolated from the interval `i1` to the interval `i2`.
    ///
    /// # Example #
    /// ```
    /// (20.0).interpolated(from: 0..100, to: 500..100) // 420
    /// ```
    public func interpolated(from i1: Interval<Self>, to i2: Interval<Self>) -> Self {
        assert(isFinite)
        assert(i1.isFinite)
        assert(i2.isFinite)
        return i2.a + ((i2.b - i2.a) * (self - i1.a)) / (i1.b - i1.a)
    }
}

extension Double {
    public static func random(in interval: Interval<Self>) -> Self {
        random(in: ClosedRange(interval))
    }

    public static func random<T: RandomNumberGenerator>(in interval: Interval<Self>, using generator: inout T) -> Self {
        random(in: ClosedRange(interval), using: &generator)
    }
}

extension Float {
    public static func random(in interval: Interval<Self>) -> Self {
        random(in: ClosedRange(interval))
    }

    public static func random<T: RandomNumberGenerator>(in interval: Interval<Self>, using generator: inout T) -> Self {
        random(in: ClosedRange(interval), using: &generator)
    }
}

#if canImport(CoreGraphics)
import CoreGraphics

extension CGFloat {
    public static func random(in interval: Interval<Self>) -> Self {
        random(in: ClosedRange(interval))
    }

    public static func random<T: RandomNumberGenerator>(in interval: Interval<Self>, using generator: inout T) -> Self {
        random(in: ClosedRange(interval), using: &generator)
    }
}

#endif
