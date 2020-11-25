//
// IntervalTests.swift
//
// © 2020 Wolf McNally
// https://wolfmcnally.com
// MIT License
//

import XCTest
import Interval

final class IntervalTests: XCTestCase {
    func testConstruct() {
        XCTAssertEqual(Interval(10, 20), 10..20)
    }

    func testUnit() {
        XCTAssertEqual(Interval<Double>.unit, 0..1)
    }

    func testAscending() {
        XCTAssertTrue((0..100).isAscending)
        XCTAssertFalse((0..100).isDescending)
        XCTAssertTrue((100..0).isDescending)
        XCTAssertFalse((100..0).isAscending)
    }

    func testEmpty() {
        XCTAssertFalse((0..100).isEmpty)
        XCTAssertTrue((50..50).isEmpty)
    }

    func testReversed() {
        XCTAssertEqual((0..100).reversed, 100..0)
    }

    func testNormalized() {
        XCTAssertEqual((0..100).normalized, 0..100)
        XCTAssertEqual((100..0).normalized, 0..100)
    }

    func testMinMax() {
        XCTAssertEqual((0..100).min, 0)
        XCTAssertEqual((0..100).max, 100)
    }

    func testExtent() {
        XCTAssertEqual((0..100).extent, 100)
        XCTAssertEqual((100..0).extent, -100)
    }

    func testContainsValue() {
        XCTAssertTrue((0..100).contains(0))
        XCTAssertTrue((0..100).contains(50))
        XCTAssertTrue((0..100).contains(100))
        XCTAssertFalse((0..100).contains(200))
    }

    func testContainsInterval() {
        XCTAssertFalse((30..50).contains(0..100))
        XCTAssertTrue((0..100).contains(30..50))
        XCTAssertTrue((0..100).contains(1..10))
        XCTAssertTrue((0..100).contains(10..1))
        XCTAssertFalse((0..100).contains(-5..10))
        XCTAssertTrue((0..100).contains(90..100))
        XCTAssertFalse((0..100).contains(200..101))
    }

    func testIntersects() {
        XCTAssertTrue((0..100).intersects(with: 20..30))
        XCTAssertTrue((20..30).intersects(with: 0..100))
        XCTAssertFalse((20..30).intersects(with: 50..100))
        XCTAssertFalse((110..150).intersects(with: 50..100))
        XCTAssertTrue((20..60).intersects(with: 50..100))
        XCTAssertTrue((80..150).intersects(with: 50..100))
    }

    func testIntersection() {
        XCTAssertEqual((0..100).intersection(with: 20..30), 20..30)
        XCTAssertEqual((20..30).intersection(with: 0..100), 20..30)
        XCTAssertNil((20..30).intersection(with: 50..100))
        XCTAssertNil((110..150).intersection(with: 50..100))
        XCTAssertEqual((20..60).intersection(with: 50..100), 50..60)
        XCTAssertEqual((80..150).intersection(with: 50..100), 80..100)
    }

    func testUnion() {
        XCTAssertEqual((0..40).union(with: (60..100)), 0..100)
        XCTAssertEqual((0 .. -60).union(with: (40..100)), -60..100)
        XCTAssertEqual((0..50).union(with: (50..100)), 0..100)
        XCTAssertEqual((70..60).union(with: (50..100)), 50..100)
    }

    func testDescription() {
        XCTAssertEqual((70..90).description, "70.0..90.0")
        XCTAssertEqual((70..90).debugDescription, "Interval(70.0..90.0)")
    }

    func testClosedRange() {
        XCTAssertEqual(ClosedRange(70..90), 70...90)
        XCTAssertEqual(ClosedRange(90..70), 70...90)
        XCTAssertEqual(Interval(70...90), 70..90)
    }

    func testIsFinite() {
        XCTAssertTrue((10..20).isFinite)
        XCTAssertFalse((Double.nan..20).isFinite)
        XCTAssertFalse((20..Double.infinity).isFinite)
    }

    func testInterpolateTo() {
        XCTAssertEqual((-0.1).interpolated(to: 0..100), -10)
        XCTAssertEqual((0.0).interpolated(to: 0..100), 0)
        XCTAssertEqual((0.1).interpolated(to: 0..100), 10)
        XCTAssertEqual((1.0).interpolated(to: 0..100), 100)
        XCTAssertEqual(round((1.1).interpolated(to: 0..100)), 110)
        XCTAssertEqual((0.5).interpolated(to: 20..30), 25)
    }

    func testInterpolateFrom() {
        XCTAssertEqual((-10.0).interpolated(from: 0..100), -0.1)
        XCTAssertEqual((0.0).interpolated(from: 0..100), 0)
        XCTAssertEqual((10.0).interpolated(from: 0..100), 0.1)
        XCTAssertEqual((100.0).interpolated(from: 0..100), 1)
        XCTAssertEqual((110.0).interpolated(from: 0..100), 1.1)
        XCTAssertEqual((25.0).interpolated(from: 20..30), 0.5)
    }

    func testInterpolateFromTo() {
        XCTAssertEqual((20.0).interpolated(from: 0..100, to: 100..0), 80)
        XCTAssertEqual((20.0).interpolated(from: 0..100, to: 100..500), 180)
        XCTAssertEqual((20.0).interpolated(from: 0..100, to: 500..100), 420)
    }
}
