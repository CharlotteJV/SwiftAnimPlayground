//
//  AnimationCurve.swift
//  AnimationDemo
//

import Foundation
import SwiftUI

enum AnimationCurve: String, CaseIterable, Identifiable {
    case defaultCurve = ".default"
    case linear = ".linear"
    case easeIn = ".easeIn"
    case easeOut = ".easeOut"
    case easeInOut = ".easeInOut"
    case smooth = ".smooth"
    case spring = ".spring"
    case snappy = ".snappy"
    case bouncy = ".bouncy"
    case interpolatingSpring = ".interpolatingSpring"
    case interactiveSpring = ".interactiveSpring"

    var id: String { rawValue }

    var isInteractive: Bool {
        switch self {
        case .interpolatingSpring, .interactiveSpring:
            return true
        default:
            return false
        }
    }

    static var standardCurves: [AnimationCurve] {
        allCases.filter { !$0.isInteractive }
    }

    static var interactiveCurves: [AnimationCurve] {
        allCases.filter { $0.isInteractive }
    }
}

// MARK: - Curve Metadata

extension AnimationCurve {
    var curveDescription: String {
        switch self {
        case .defaultCurve:
            return "The system default animation. In iOS 17+, this is equivalent to .smooth - a spring animation with no bounce that provides natural, fluid transitions across the Apple ecosystem."
        case .linear:
            return "Moves at a constant speed from start to finish. No acceleration or deceleration. Useful for continuous animations like progress bars or loading indicators."
        case .easeIn:
            return "Starts slowly and then increases speed towards the end. Creates a sense of building momentum. Best for elements exiting the screen or fading out."
        case .easeOut:
            return "Starts fast and decelerates toward the end. Creates a natural settling effect. Ideal for elements entering the screen or appearing."
        case .easeInOut:
            return "Combines ease-in and ease-out: starts slow, speeds up in the middle, then slows down at the end. A balanced curve suitable for most UI animations."
        case .smooth:
            return "A smooth spring animation with a predefined duration and no bounce. This is the default animation across the Apple ecosystem, used for app launches, navigation, and elegant transitions."
        case .spring:
            return "A persistent spring animation. The bounce parameter (0-1) controls how much the animation overshoots its target. When mixed with other spring animations, velocity is preserved between them."
        case .snappy:
            return "A spring animation with a predefined duration and small amount of bounce that feels more snappy. Ideal for responsive UI feedback like toggles and buttons."
        case .bouncy:
            return "A spring animation with a predefined duration and higher amount of bounce. Creates playful, exaggerated animations perfect for delightful UI moments."
        case .interpolatingSpring:
            return "An interpolating spring using stiffness and damping coefficients. When triggered multiple times rapidly, spring effects combine and strengthen. Higher stiffness = faster, higher damping = less oscillation."
        case .interactiveSpring:
            return "A spring animation with lower response value, intended for driving interactive animations. Optimized for gesture-driven interactions like drag-and-release with natural spring-back behavior."
        }
    }
}

// MARK: - Parameter Specifications (Single Source of Truth)

extension AnimationCurve {

    /// The authoritative parameter definitions for this curve type.
    /// All UI, animation building, and code generation should use these specs.
    var parameterSpecs: [AnimationParameterSpec] {
        switch self {
        case .defaultCurve:
            return []

        case .linear, .easeIn, .easeOut, .easeInOut:
            return [.duration(default: 0.35, range: 0.1...2.0)]

        case .smooth:
            return [
                .duration(default: 0.5),
                .extraBounce(default: 0.0)
            ]

        case .spring:
            return [
                .duration(default: 0.5),
                .bounce(default: 0.3)
            ]

        case .snappy:
            return [
                .duration(default: 0.5),
                .extraBounce(default: 0.0)
            ]

        case .bouncy:
            return [
                .duration(default: 0.5),
                .extraBounce(default: 0.0)
            ]

        case .interpolatingSpring:
            return [
                .stiffness(default: 170),
                .damping(default: 15)
            ]

        case .interactiveSpring:
            return [
                .response(default: 0.4),
                .dampingFraction(default: 0.7)
            ]
        }
    }

    /// Returns editable parameters (excludes duration which is often controlled globally)
    var editableParameterSpecs: [AnimationParameterSpec] {
        parameterSpecs.filter { $0.id != "duration" }
    }

    /// Default values dictionary for initializing parameter state
    var defaultParameterValues: [String: Double] {
        Dictionary(uniqueKeysWithValues: parameterSpecs.map { ($0.id, $0.defaultValue) })
    }

    // MARK: - Animation Building

    /// Builds a SwiftUI Animation from parameter values.
    /// - Parameters:
    ///   - values: Dictionary of parameter values (e.g., ["bounce": 0.5])
    ///   - duration: Optional override for duration (used when duration is controlled globally)
    func buildAnimation(with values: [String: Double], duration: Double? = nil) -> Animation {
        switch self {
        case .defaultCurve:
            return .default

        case .linear:
            return .linear(duration: duration ?? values["duration"] ?? 0.35)

        case .easeIn:
            return .easeIn(duration: duration ?? values["duration"] ?? 0.35)

        case .easeOut:
            return .easeOut(duration: duration ?? values["duration"] ?? 0.35)

        case .easeInOut:
            return .easeInOut(duration: duration ?? values["duration"] ?? 0.35)

        case .smooth:
            return .smooth(
                duration: duration ?? values["duration"] ?? 0.5,
                extraBounce: values["extraBounce"] ?? 0.0
            )

        case .spring:
            return .spring(
                duration: duration ?? values["duration"] ?? 0.5,
                bounce: values["bounce"] ?? 0.3
            )

        case .snappy:
            return .snappy(
                duration: duration ?? values["duration"] ?? 0.5,
                extraBounce: values["extraBounce"] ?? 0.0
            )

        case .bouncy:
            return .bouncy(
                duration: duration ?? values["duration"] ?? 0.5,
                extraBounce: values["extraBounce"] ?? 0.0
            )

        case .interpolatingSpring:
            return .interpolatingSpring(
                stiffness: values["stiffness"] ?? 170,
                damping: values["damping"] ?? 15
            )

        case .interactiveSpring:
            return .interactiveSpring(
                response: values["response"] ?? 0.4,
                dampingFraction: values["dampingFraction"] ?? 0.7
            )
        }
    }

    // MARK: - Code String Generation

    /// Generates a code string representation for display/copy.
    func codeString(with values: [String: Double], duration: Double? = nil) -> String {
        switch self {
        case .defaultCurve:
            return ".default"

        case .linear:
            let d = duration ?? values["duration"] ?? 0.35
            return ".linear(duration: \(formatDouble(d, decimals: 1)))"

        case .easeIn:
            let d = duration ?? values["duration"] ?? 0.35
            return ".easeIn(duration: \(formatDouble(d, decimals: 1)))"

        case .easeOut:
            let d = duration ?? values["duration"] ?? 0.35
            return ".easeOut(duration: \(formatDouble(d, decimals: 1)))"

        case .easeInOut:
            let d = duration ?? values["duration"] ?? 0.35
            return ".easeInOut(duration: \(formatDouble(d, decimals: 1)))"

        case .smooth:
            let d = duration ?? values["duration"] ?? 0.5
            let eb = values["extraBounce"] ?? 0.0
            if eb == 0.0 {
                return ".smooth(duration: \(formatDouble(d, decimals: 1)))"
            }
            return ".smooth(duration: \(formatDouble(d, decimals: 1)), extraBounce: \(formatDouble(eb, decimals: 1)))"

        case .spring:
            let d = duration ?? values["duration"] ?? 0.5
            let b = values["bounce"] ?? 0.3
            return ".spring(duration: \(formatDouble(d, decimals: 1)), bounce: \(formatDouble(b, decimals: 1)))"

        case .snappy:
            let d = duration ?? values["duration"] ?? 0.5
            let eb = values["extraBounce"] ?? 0.0
            return ".snappy(duration: \(formatDouble(d, decimals: 1)), extraBounce: \(formatDouble(eb, decimals: 1)))"

        case .bouncy:
            let d = duration ?? values["duration"] ?? 0.5
            let eb = values["extraBounce"] ?? 0.0
            return ".bouncy(duration: \(formatDouble(d, decimals: 1)), extraBounce: \(formatDouble(eb, decimals: 1)))"

        case .interpolatingSpring:
            let s = values["stiffness"] ?? 170
            let d = values["damping"] ?? 15
            return ".interpolatingSpring(stiffness: \(formatDouble(s, decimals: 0)), damping: \(formatDouble(d, decimals: 0)))"

        case .interactiveSpring:
            let r = values["response"] ?? 0.4
            let df = values["dampingFraction"] ?? 0.7
            return ".interactiveSpring(response: \(formatDouble(r, decimals: 1)), dampingFraction: \(formatDouble(df, decimals: 1)))"
        }
    }

    private func formatDouble(_ value: Double, decimals: Int) -> String {
        String(format: "%.\(decimals)f", value)
    }
}
