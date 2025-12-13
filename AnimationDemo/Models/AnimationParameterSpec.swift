//
//  AnimationParameterSpec.swift
//  AnimationDemo
//

import Foundation

/// Unified parameter specification for animation curves.
/// Single source of truth for parameter metadata, ranges, defaults, and formatting.
struct AnimationParameterSpec: Identifiable, Equatable {
    let id: String              // Parameter key: "bounce", "extraBounce", "stiffness", etc.
    let name: String            // Display name
    let type: String            // Type name for documentation: "Double"
    let range: ClosedRange<Double>
    let defaultValue: Double
    let step: Double
    let formatDecimals: Int
    let description: String

    // MARK: - Formatting

    var rangeString: String {
        if range.upperBound == .infinity {
            return "\(formatValue(range.lowerBound))...∞"
        }
        return "\(formatValue(range.lowerBound))...\(formatValue(range.upperBound))"
    }

    var defaultValueString: String {
        formatValue(defaultValue)
    }

    func formatValue(_ value: Double) -> String {
        String(format: "%.\(formatDecimals)f", value)
    }

    // MARK: - Common Parameter Factories

    static func duration(default value: Double = 0.5, range: ClosedRange<Double> = 0.1...1.5) -> AnimationParameterSpec {
        AnimationParameterSpec(
            id: "duration",
            name: "duration",
            type: "Double",
            range: range,
            defaultValue: value,
            step: 0.1,
            formatDecimals: 1,
            description: "Animation duration in seconds"
        )
    }

    static func bounce(default value: Double = 0.3) -> AnimationParameterSpec {
        AnimationParameterSpec(
            id: "bounce",
            name: "bounce",
            type: "Double",
            range: 0.0...0.9,
            defaultValue: value,
            step: 0.1,
            formatDecimals: 1,
            description: "Bounciness: 0 = no bounce, 0.9 = maximum bounce"
        )
    }

    static func extraBounce(default value: Double = 0.0) -> AnimationParameterSpec {
        AnimationParameterSpec(
            id: "extraBounce",
            name: "extraBounce",
            type: "Double",
            range: 0.0...0.5,
            defaultValue: value,
            step: 0.1,
            formatDecimals: 1,
            description: "Additional bounce beyond the preset default"
        )
    }

    static func stiffness(default value: Double = 170) -> AnimationParameterSpec {
        AnimationParameterSpec(
            id: "stiffness",
            name: "stiffness",
            type: "Double",
            range: 50...400,
            defaultValue: value,
            step: 10,
            formatDecimals: 0,
            description: "Spring stiffness coefficient (higher = faster)"
        )
    }

    static func damping(default value: Double = 15) -> AnimationParameterSpec {
        AnimationParameterSpec(
            id: "damping",
            name: "damping",
            type: "Double",
            range: 5...40,
            defaultValue: value,
            step: 1,
            formatDecimals: 0,
            description: "Damping coefficient (higher = less oscillation)"
        )
    }

    static func response(default value: Double = 0.15) -> AnimationParameterSpec {
        AnimationParameterSpec(
            id: "response",
            name: "response",
            type: "Double",
            range: 0.1...1.0,
            defaultValue: value,
            step: 0.1,
            formatDecimals: 1,
            description: "Time to reach target (lower = faster)"
        )
    }

    static func dampingFraction(default value: Double = 0.86) -> AnimationParameterSpec {
        AnimationParameterSpec(
            id: "dampingFraction",
            name: "dampingFraction",
            type: "Double",
            range: 0.1...1.0,
            defaultValue: value,
            step: 0.1,
            formatDecimals: 1,
            description: "Damping ratio: 0 = undamped, 1 = critically damped"
        )
    }
}
