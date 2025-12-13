//
//  CurveGraphView.swift
//  AnimationDemo
//

import SwiftUI

struct CurveGraphView: View {
    let curve: AnimationCurve
    let size: CGSize

    // Dynamic parameters for spring curves
    var bounce: Double = 0.0
    var extraBounce: Double = 0.0
    var stiffness: Double = 170.0
    var damping: Double = 15.0
    var response: Double = 0.15
    var dampingFraction: Double = 0.86

    private let padding: CGFloat = 24
    private let axisColor = Color.gray.opacity(0.3)
    private let curveColor = Color.accentColor

    var body: some View {
        Canvas { context, canvasSize in
            let graphRect = CGRect(
                x: padding,
                y: padding / 2,
                width: canvasSize.width - padding * 1.5,
                height: canvasSize.height - padding * 1.5
            )

            // Generate points first to determine scale
            // More points for higher time scales to maintain smoothness
            let pointCount = Int(100 * timeScale)
            let points = generateCurvePoints(count: pointCount)
            let (minY, maxY) = calculateYBounds(points: points)

            drawAxes(context: context, rect: graphRect, minY: minY, maxY: maxY)
            drawCurve(context: context, rect: graphRect, points: points, minY: minY, maxY: maxY)
        }
        .frame(width: size.width, height: size.height)
    }

    private func calculateYBounds(points: [CGPoint]) -> (minY: Double, maxY: Double) {
        var minY = 0.0
        var maxY = 1.0

        for point in points {
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }

        // Add some padding to the bounds
        let range = maxY - minY
        let paddingAmount = range * 0.1

        minY = minY - paddingAmount
        maxY = maxY + paddingAmount

        // Ensure we always show at least 0 to 1
        minY = min(minY, 0)
        maxY = max(maxY, 1)

        return (minY, maxY)
    }

    private func drawAxes(context: GraphicsContext, rect: CGRect, minY: Double, maxY: Double) {
        let range = maxY - minY

        // Calculate where y=0 and y=1 are in screen coordinates
        let y0Screen = rect.maxY - ((0 - minY) / range) * rect.height
        let y1Screen = rect.maxY - ((1 - minY) / range) * rect.height

        var axisPath = Path()

        // Y axis
        axisPath.move(to: CGPoint(x: rect.minX, y: rect.minY))
        axisPath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        // X axis at y=0
        axisPath.move(to: CGPoint(x: rect.minX, y: y0Screen))
        axisPath.addLine(to: CGPoint(x: rect.maxX, y: y0Screen))

        context.stroke(axisPath, with: .color(axisColor), lineWidth: 1)

        // Draw axis labels
        let labelFont = Font.system(size: 9)

        // "0" at y=0 line
        context.draw(
            Text("0").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.minX - 8, y: y0Screen)
        )

        // "1" at y=1 line
        context.draw(
            Text("1").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.minX - 8, y: y1Screen)
        )

        // "t" at end of X axis
        context.draw(
            Text("t").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.maxX + 6, y: y0Screen + 8)
        )

        // Draw dashed line at y=1 for reference
        if curve.isSpringBased {
            var refPath = Path()
            refPath.move(to: CGPoint(x: rect.minX, y: y1Screen))
            refPath.addLine(to: CGPoint(x: rect.maxX, y: y1Screen))
            context.stroke(
                refPath,
                with: .color(Color.gray.opacity(0.2)),
                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
            )
        }
    }

    private func drawCurve(context: GraphicsContext, rect: CGRect, points: [CGPoint], minY: Double, maxY: Double) {
        let range = maxY - minY

        var curvePath = Path()
        for (index, point) in points.enumerated() {
            let x = rect.minX + point.x * rect.width
            // Map y value to screen coordinates with dynamic scaling
            let normalizedY = (point.y - minY) / range
            let y = rect.maxY - normalizedY * rect.height

            if index == 0 {
                curvePath.move(to: CGPoint(x: x, y: y))
            } else {
                curvePath.addLine(to: CGPoint(x: x, y: y))
            }
        }

        context.stroke(curvePath, with: .color(curveColor), lineWidth: 2)
    }

    /// Calculates the time scale factor based on curve bounciness
    /// Higher bounce = longer time range to show more oscillations
    private var timeScale: Double {
        switch curve {
        case .spring:
            // Extend time range as bounce increases (1.0 at bounce=0, up to 2.0 at bounce=0.9)
            return 1.0 + bounce * 1.2
        case .smooth:
            return 1.0 + extraBounce * 1.0
        case .snappy:
            return 1.0 + extraBounce * 0.8
        case .bouncy:
            // Bouncy needs more time to show all oscillations
            return 1.2 + extraBounce * 1.0
        case .interpolatingSpring:
            // Lower damping = more oscillations = need more time
            let dampingRatio = damping / (2.0 * sqrt(stiffness))
            return dampingRatio < 0.5 ? 1.5 : 1.0
        case .interactiveSpring:
            return 1.0 + (1.0 - dampingFraction) * 0.8
        default:
            return 1.0
        }
    }

    private func generateCurvePoints(count: Int) -> [CGPoint] {
        let scale = timeScale
        return (0..<count).map { i in
            let normalizedX = Double(i) / Double(count - 1)
            let t = normalizedX * scale  // Scale time to show more oscillations
            let y = curveValue(at: t)
            return CGPoint(x: normalizedX, y: y)  // X stays 0-1 for display
        }
    }

    private func curveValue(at t: Double) -> Double {
        switch curve {
        case .defaultCurve, .easeInOut:
            return cubicBezier(t: t, p1: CGPoint(x: 0.42, y: 0), p2: CGPoint(x: 0.58, y: 1))
        case .linear:
            return t
        case .easeIn:
            return cubicBezier(t: t, p1: CGPoint(x: 0.42, y: 0), p2: CGPoint(x: 1.0, y: 1))
        case .easeOut:
            return cubicBezier(t: t, p1: CGPoint(x: 0, y: 0), p2: CGPoint(x: 0.58, y: 1))
        case .smooth:
            // Smooth: no bounce by default, extraBounce adds bounciness
            return springValue(t: t, bounce: extraBounce * 1.2)
        case .spring:
            return springValue(t: t, bounce: bounce)
        case .snappy:
            // Snappy: small base bounce + extraBounce amplifies it
            return springValue(t: t, bounce: 0.2 + extraBounce * 1.0)
        case .bouncy:
            // Bouncy: higher base bounce + extraBounce for pronounced oscillations
            return springValue(t: t, bounce: 0.5 + extraBounce * 0.9)
        case .interpolatingSpring:
            return interpolatingSpringValue(t: t, stiffness: stiffness, damping: damping)
        case .interactiveSpring:
            return interactiveSpringValue(t: t, response: response, dampingFraction: dampingFraction)
        }
    }

    // Cubic bezier easing
    private func cubicBezier(t: Double, p1: CGPoint, p2: CGPoint) -> Double {
        // Approximate cubic bezier - for visualization purposes
        let cx = 3.0 * p1.x
        let bx = 3.0 * (p2.x - p1.x) - cx
        let ax = 1.0 - cx - bx

        let cy = 3.0 * p1.y
        let by = 3.0 * (p2.y - p1.y) - cy
        let ay = 1.0 - cy - by

        // Find t for x using Newton-Raphson
        var tCurve = t
        for _ in 0..<8 {
            let xCurrent = ((ax * tCurve + bx) * tCurve + cx) * tCurve
            let xDerivative = (3.0 * ax * tCurve + 2.0 * bx) * tCurve + cx
            if abs(xDerivative) < 1e-6 { break }
            tCurve = tCurve - (xCurrent - t) / xDerivative
        }

        return ((ay * tCurve + by) * tCurve + cy) * tCurve
    }

    // Spring with bounce parameter
    private func springValue(t: Double, bounce: Double) -> Double {
        if t <= 0.0 { return 0.0 }

        // Convert bounce (0-1+) to damping ratio
        // Higher bounce = lower damping = more oscillation
        // Clamp bounce to reasonable range for the formula
        let clampedBounce = min(bounce, 1.4)
        let dampingRatio = max(0.1, 1.0 - clampedBounce * 0.85)
        let omega = 12.0 // Natural frequency (higher = faster oscillations)

        if dampingRatio >= 1.0 {
            // Critically damped or overdamped
            let decay = exp(-omega * t)
            return 1.0 - decay * (1.0 + omega * t)
        } else {
            // Underdamped (oscillating)
            let omegaD = omega * sqrt(1.0 - dampingRatio * dampingRatio)
            let decay = exp(-dampingRatio * omega * t)
            return 1.0 - decay * (cos(omegaD * t) + (dampingRatio * omega / omegaD) * sin(omegaD * t))
        }
    }

    // Interpolating spring with stiffness and damping
    private func interpolatingSpringValue(t: Double, stiffness: Double, damping: Double) -> Double {
        if t <= 0.0 { return 0.0 }

        // Mass is assumed to be 1
        let omega = sqrt(stiffness) // Natural frequency
        let dampingRatio = damping / (2.0 * sqrt(stiffness))

        if dampingRatio >= 1.0 {
            let r1 = -omega * (dampingRatio - sqrt(dampingRatio * dampingRatio - 1))
            let r2 = -omega * (dampingRatio + sqrt(dampingRatio * dampingRatio - 1))
            let c2 = -r1 / (r2 - r1)
            let c1 = 1.0 - c2
            return 1.0 - (c1 * exp(r1 * t) + c2 * exp(r2 * t))
        } else {
            let omegaD = omega * sqrt(1.0 - dampingRatio * dampingRatio)
            let decay = exp(-dampingRatio * omega * t)
            return 1.0 - decay * (cos(omegaD * t) + (dampingRatio * omega / omegaD) * sin(omegaD * t))
        }
    }

    // Interactive spring with response and dampingFraction
    private func interactiveSpringValue(t: Double, response: Double, dampingFraction: Double) -> Double {
        if t <= 0.0 { return 0.0 }

        // Convert response to natural frequency
        let omega = 2.0 * .pi / response
        let dampingRatio = dampingFraction

        if dampingRatio >= 1.0 {
            let decay = exp(-omega * t)
            return 1.0 - decay * (1.0 + omega * t)
        } else {
            let omegaD = omega * sqrt(1.0 - dampingRatio * dampingRatio)
            let decay = exp(-dampingRatio * omega * t)
            return 1.0 - decay * (cos(omegaD * t) + (dampingRatio * omega / omegaD) * sin(omegaD * t))
        }
    }
}

extension AnimationCurve {
    var isSpringBased: Bool {
        switch self {
        case .spring, .snappy, .bouncy, .smooth, .interpolatingSpring, .interactiveSpring:
            return true
        default:
            return false
        }
    }
}
