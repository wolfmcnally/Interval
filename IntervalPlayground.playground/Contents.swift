//
// IntervalPlayground.swift
//
// © 2020 Wolf McNally
// https://wolfmcnally.com
// MIT License
//

import Foundation
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
