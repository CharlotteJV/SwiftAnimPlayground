//
//  ComparisonSlot.swift
//  AnimationDemo
//

import SwiftUI

struct ComparisonSlot: Identifiable, Equatable {
    let id = UUID()
    var curve: AnimationCurve
    var parameterValues: [String: Double] = [:]
    var isAnimated: Bool = false
    var color: Color

    static let slotColors: [Color] = [.blue, .orange, .green]

    init(curve: AnimationCurve, color: Color) {
        self.curve = curve
        self.color = color
        self.parameterValues = curve.defaultParameterValues
    }

    /// Builds animation using centralized AnimationCurve.buildAnimation
    func animation(duration: Double) -> Animation {
        curve.buildAnimation(with: parameterValues, duration: duration)
    }

    /// Returns editable parameters for this curve (excludes duration)
    var editableParameters: [AnimationParameterSpec] {
        curve.editableParameterSpecs
    }

    /// Whether this curve has editable parameters
    var hasParameters: Bool {
        !editableParameters.isEmpty
    }

    /// Updates parameter values when curve changes
    mutating func updateCurve(_ newCurve: AnimationCurve) {
        curve = newCurve
        parameterValues = newCurve.defaultParameterValues
    }
}
