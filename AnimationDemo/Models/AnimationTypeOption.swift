//
//  AnimationTypeOption.swift
//  AnimationDemo
//

import SwiftUI

/// Legacy type kept for backward compatibility with example views.
/// Converts AnimationParameterSpec to ParameterDefinition format.
struct ParameterDefinition {
    let name: String
    let defaultValue: Double
    let range: ClosedRange<Double>
    let formatDecimals: Int

    init(name: String, defaultValue: Double, range: ClosedRange<Double>, formatDecimals: Int = 2) {
        self.name = name
        self.defaultValue = defaultValue
        self.range = range
        self.formatDecimals = formatDecimals
    }

    /// Creates a ParameterDefinition from an AnimationParameterSpec
    init(from spec: AnimationParameterSpec) {
        self.name = spec.name
        self.defaultValue = spec.defaultValue
        self.range = spec.range
        self.formatDecimals = spec.formatDecimals
    }
}

enum AnimationTypeOption: String, CaseIterable, Identifiable {
    case spring
    case smooth
    case snappy
    case bouncy
    case easeIn
    case easeOut
    case easeInOut
    case linear
    case interpolatingSpring

    var id: String { rawValue }

    // MARK: - Bridge to AnimationCurve (Single Source of Truth)

    /// Maps to the corresponding AnimationCurve for centralized parameter management
    var animationCurve: AnimationCurve {
        switch self {
        case .spring: return .spring
        case .smooth: return .smooth
        case .snappy: return .snappy
        case .bouncy: return .bouncy
        case .easeIn: return .easeIn
        case .easeOut: return .easeOut
        case .easeInOut: return .easeInOut
        case .linear: return .linear
        case .interpolatingSpring: return .interpolatingSpring
        }
    }

    var displayName: String {
        animationCurve.rawValue
    }

    // MARK: - Parameters (Delegated to AnimationCurve)

    /// Parameters derived from AnimationCurve.parameterSpecs
    var parameters: [ParameterDefinition] {
        animationCurve.parameterSpecs.map { ParameterDefinition(from: $0) }
    }

    var defaultParameters: [String: Double] {
        animationCurve.defaultParameterValues
    }

    // MARK: - Animation Building (Delegated to AnimationCurve)

    func buildAnimation(with values: [String: Double]) -> Animation {
        animationCurve.buildAnimation(with: values)
    }

    // MARK: - Code String (Delegated to AnimationCurve)

    func codeString(with values: [String: Double]) -> String {
        animationCurve.codeString(with: values)
    }
}
