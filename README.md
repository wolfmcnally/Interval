# Floating Point Interval for Swift

When working on code where I'm doing a lot of calculation in geometric spaces such as layout, animation, or color, I often find myself using the concept of a floating point *interval*: a closed range on the floating point number line. However, the existing `ClosedRange` requires its bounds to be ordered, which makes it less than useful for geometric calculations where a coordinates can travel or be interpolated in either direction.

I have developed a type, `Interval` along with an operator to construct such intervals that I have found very useful, and think others might find it useful too. It might be worth considering including in the Standard Library.

## Definition

The basic type is defined as follows:

```swift
public struct Interval<T: BinaryFloatingPoint> : Equatable {
    public typealias Bound = T

    public let a: Bound
    public let b: Bound

    public init(_ a: Bound, _ b: Bound) {
        self.a = a
        self.b = b
    }
}
```

## Interval Formation Operator

In addition, a new *interval formation operator* is introduced:

```swift
infix operator .. : RangeFormationPrecedence

public func .. <T>(left: T, right: T) -> Interval<T> {
    Interval(left, right)
}
```

This operator, like the range formation operators, makes it easy to create Intervals in code:

```swift
let i = 0..100
let j = 100..3.14
```

In practice I have not found any trouble keeping the new operator `..` and the existing range formation operators `...` and `..<` distinct in my mind.

## Geometric Queries

Unlike `ClosedRange`, `a` and `b` can be in any order. This means this type has to deal with the various cases that entails, and thus it also provides computed attributes like:

| | |
|:---|:---|
| `isAscending` | is `a` < `b`? |
| `isDescending` | is `a` > `b`? |
| `isEmpty` | is `a` == `b`? This is different from `ClosedRange`, which always returns `true`. |
| `reversed` | `Interval(b, a)`
| `normalized` | returns Interval with values ordered so `isAscending` is `true`
| `min` | `min(a, b)`
| `max` | `max(a, b)`

Because `Interval` is designed to be used with geometric calculations, it contains a number of geometric operators:

| | |
|:---|:---|
| `extent` | `b - a` |
| `contains` | Does `self` contain a particular coordinate? |
| `contains` | Does `self` fully contain another `Interval`? |
| `intersects` | Does `self` intersect (overlap) another `Interval`? |
| `intersection` | Returns an `Interval` which is the overlapping part of `self` and another `Interval`, or `nil` if they don't intersect. |
| `union` | Returns an `Interval` subtending the greatest extents of `self` and another interval.

## Linear Interpolation

One place `Interval` shines is when you need to do linear interpolation. An extension on `BinaryFloatingPoint` makes every one of these types interpolable into and out of normalized unit spaces and between spaces.

Interpolation is not clamped, so interpolating a value outside the interval `0..1` to another interval results in extrapolation.

```swift
extension BinaryFloatingPoint {
    /// The value linearly interpolated from the unit interval `0..1` to the interval `a..b`.
    public func interpolated(to i: Interval<Self>) -> Self

    /// The value linearly interpolated from the interval `a..b` into the unit interval `0..1`.
    public func interpolated(from i: Interval<Self>) -> Self

    /// The value linearly interpolated from the interval `i1` to the interval `i2`.
    public func interpolated(from i1: Interval<Self>, to i2: Interval<Self>) -> Self
}
```

Here is an example of using `Interval` to interpolate between two colors:

```swift
import Interval

struct Color : CustomStringConvertible {
    let r, g, b: Double

    private func f(_ n: Double) -> String { return String(format: "%.2f", n) }

    var description: String { "(r: \(f(r)), g: \(f(g)), b: \(f(b)))" }

    func interpolated(to other: Color, at t: Double) -> Color {
        Color(
            r: t.interpolated(to: r..other.r),
            g: t.interpolated(to: g..other.g),
            b: t.interpolated(to: b..other.b)
        )
    }
}

let darkTurquoise = Color(r: 0, g: 0.8, b: 0.81)
let salmon = Color(r: 0.98, g: 0.5, b: 0.45)

for t in stride(from: 0.0, to: 1.1, by: 0.1) {
    let c = darkTurquoise.interpolated(to: salmon, at: t)
    print(String(format: "%.1f", t) + ": " + c.description)
}
```

When run, the output below is produced. Notice that the `r` value is increasing while `g` and `b` are decreasing.

```
0.0: (r: 0.00, g: 0.80, b: 0.81)
0.1: (r: 0.10, g: 0.77, b: 0.77)
0.2: (r: 0.20, g: 0.74, b: 0.74)
0.3: (r: 0.29, g: 0.71, b: 0.70)
0.4: (r: 0.39, g: 0.68, b: 0.67)
0.5: (r: 0.49, g: 0.65, b: 0.63)
0.6: (r: 0.59, g: 0.62, b: 0.59)
0.7: (r: 0.69, g: 0.59, b: 0.56)
0.8: (r: 0.78, g: 0.56, b: 0.52)
0.9: (r: 0.88, g: 0.53, b: 0.49)
1.0: (r: 0.98, g: 0.50, b: 0.45)
```

## Interoperability with ClosedRange

To provide interoperability with `ClosedRange`, conversion constructors are provided. When converting from `Interval` to `ClosedRange`, the bounds are normalized so `a` <= `b`.

```swift
extension Interval {
    public init(_ r: ClosedRange<Bound>)
}

extension ClosedRange where Bound: BinaryFloatingPoint {
    public init(_ i: Interval<Bound>)
}
```

## Interoperability with Random Number Generation

Extensions on `Float`, `Double`, and `CGFloat` provide the ability to produce random numbers in an interval.

```swift
extension Double {
	public static func random(in interval: Interval<Self>) -> Self
	public static func random<T: RandomNumberGenerator>(in interval: Interval<Self>, using generator: inout T) -> Self
}
```