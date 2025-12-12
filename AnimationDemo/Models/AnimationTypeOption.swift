//
//  AnimationTypeOption.swift
//  AnimationDemo
//

import SwiftUI

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

    var displayName: String {
        switch self {
        case .spring: return ".spring"
        case .smooth: return ".smooth"
        case .snappy: return ".snappy"
        case .bouncy: return ".bouncy"
        case .easeIn: return ".easeIn"
        case .easeOut: return ".easeOut"
        case .easeInOut: return ".easeInOut"
        case .linear: return ".linear"
        case .interpolatingSpring: return ".interpolatingSpring"
        }
    }

    var parameters: [ParameterDefinition] {
        switch self {
        case .spring:
            return [
                ParameterDefinition(name: "duration", defaultValue: 0.4, range: 0.1...1.0),
                ParameterDefinition(name: "bounce", defaultValue: 0.3, range: 0.0...1.0)
            ]
        case .smooth:
            return [
                ParameterDefinition(name: "duration", defaultValue: 0.4, range: 0.1...1.0)
            ]
        case .snappy:
            return [
                ParameterDefinition(name: "duration", defaultValue: 0.4, range: 0.1...1.0),
                ParameterDefinition(name: "extraBounce", defaultValue: 0.0, range: 0.0...1.0)
            ]
        case .bouncy:
            return [
                ParameterDefinition(name: "duration", defaultValue: 0.4, range: 0.1...1.0),
                ParameterDefinition(name: "extraBounce", defaultValue: 0.0, range: 0.0...1.0)
            ]
        case .easeIn, .easeOut, .easeInOut, .linear:
            return [
                ParameterDefinition(name: "duration", defaultValue: 0.4, range: 0.1...2.0)
            ]
        case .interpolatingSpring:
            return [
                ParameterDefinition(name: "stiffness", defaultValue: 150, range: 50...400, formatDecimals: 0),
                ParameterDefinition(name: "damping", defaultValue: 15, range: 5...30, formatDecimals: 0)
            ]
        }
    }

    var defaultParameters: [String: Double] {
        var result: [String: Double] = [:]
        for param in parameters {
            result[param.name] = param.defaultValue
        }
        return result
    }

    func buildAnimation(with values: [String: Double]) -> Animation {
        switch self {
        case .spring:
            let duration = values["duration"] ?? 0.4
            let bounce = values["bounce"] ?? 0.3
            return .spring(duration: duration, bounce: bounce)

        case .smooth:
            let duration = values["duration"] ?? 0.4
            return .smooth(duration: duration)

        case .snappy:
            let duration = values["duration"] ?? 0.4
            let extraBounce = values["extraBounce"] ?? 0.0
            return .snappy(duration: duration, extraBounce: extraBounce)

        case .bouncy:
            let duration = values["duration"] ?? 0.4
            let extraBounce = values["extraBounce"] ?? 0.0
            return .bouncy(duration: duration, extraBounce: extraBounce)

        case .easeIn:
            let duration = values["duration"] ?? 0.4
            return .easeIn(duration: duration)

        case .easeOut:
            let duration = values["duration"] ?? 0.4
            return .easeOut(duration: duration)

        case .easeInOut:
            let duration = values["duration"] ?? 0.4
            return .easeInOut(duration: duration)

        case .linear:
            let duration = values["duration"] ?? 0.4
            return .linear(duration: duration)

        case .interpolatingSpring:
            let stiffness = values["stiffness"] ?? 150
            let damping = values["damping"] ?? 15
            return .interpolatingSpring(stiffness: stiffness, damping: damping)
        }
    }

    func codeString(with values: [String: Double]) -> String {
        switch self {
        case .spring:
            let duration = values["duration"] ?? 0.4
            let bounce = values["bounce"] ?? 0.3
            return ".spring(duration: \(String(format: "%.2f", duration)), bounce: \(String(format: "%.2f", bounce)))"

        case .smooth:
            let duration = values["duration"] ?? 0.4
            return ".smooth(duration: \(String(format: "%.2f", duration)))"

        case .snappy:
            let duration = values["duration"] ?? 0.4
            let extraBounce = values["extraBounce"] ?? 0.0
            return ".snappy(duration: \(String(format: "%.2f", duration)), extraBounce: \(String(format: "%.2f", extraBounce)))"

        case .bouncy:
            let duration = values["duration"] ?? 0.4
            let extraBounce = values["extraBounce"] ?? 0.0
            return ".bouncy(duration: \(String(format: "%.2f", duration)), extraBounce: \(String(format: "%.2f", extraBounce)))"

        case .easeIn:
            let duration = values["duration"] ?? 0.4
            return ".easeIn(duration: \(String(format: "%.2f", duration)))"

        case .easeOut:
            let duration = values["duration"] ?? 0.4
            return ".easeOut(duration: \(String(format: "%.2f", duration)))"

        case .easeInOut:
            let duration = values["duration"] ?? 0.4
            return ".easeInOut(duration: \(String(format: "%.2f", duration)))"

        case .linear:
            let duration = values["duration"] ?? 0.4
            return ".linear(duration: \(String(format: "%.2f", duration)))"

        case .interpolatingSpring:
            let stiffness = values["stiffness"] ?? 150
            let damping = values["damping"] ?? 15
            return ".interpolatingSpring(stiffness: \(String(format: "%.0f", stiffness)), damping: \(String(format: "%.0f", damping)))"
        }
    }
}
