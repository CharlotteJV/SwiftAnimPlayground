//
//  CompareCurveGraphView.swift
//  AnimationDemo
//

import SwiftUI

struct CompareCurveGraphView: View {
    let slots: [ComparisonSlot]
    let size: CGSize

    private let padding: CGFloat = 24
    private let axisColor = Color.gray.opacity(0.3)

    var body: some View {
        Canvas { context, canvasSize in
            let graphRect = CGRect(
                x: padding,
                y: padding / 2,
                width: canvasSize.width - padding * 1.5,
                height: canvasSize.height - padding * 1.5
            )

            // Generate points for all slots to determine unified scale
            var allPoints: [(slot: ComparisonSlot, points: [CGPoint])] = []
            var globalMinY = 0.0
            var globalMaxY = 1.0

            for slot in slots {
                let scale = timeScale(for: slot)
                let pointCount = Int(100 * scale)
                let points = generateCurvePoints(for: slot, count: pointCount, timeScale: scale)
                allPoints.append((slot, points))

                for point in points {
                    globalMinY = min(globalMinY, point.y)
                    globalMaxY = max(globalMaxY, point.y)
                }
            }

            // Add padding to bounds
            let range = globalMaxY - globalMinY
            let paddingAmount = range * 0.1
            globalMinY = min(globalMinY - paddingAmount, 0)
            globalMaxY = max(globalMaxY + paddingAmount, 1)

            drawAxes(context: context, rect: graphRect, minY: globalMinY, maxY: globalMaxY)

            // Draw each curve
            for (slot, points) in allPoints {
                drawCurve(context: context, rect: graphRect, points: points, minY: globalMinY, maxY: globalMaxY, color: slot.color)
            }
        }
        .frame(width: size.width, height: size.height)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.03))
        )
    }

    private func timeScale(for slot: ComparisonSlot) -> Double {
        let curve = slot.curve
        let params = slot.parameterValues

        switch curve {
        case .spring:
            let bounce = params["bounce"] ?? 0.3
            return 1.0 + bounce * 1.2
        case .smooth:
            let extraBounce = params["extraBounce"] ?? 0.0
            return 1.0 + extraBounce * 1.0
        case .snappy:
            let extraBounce = params["extraBounce"] ?? 0.0
            return 1.0 + extraBounce * 0.8
        case .bouncy:
            let extraBounce = params["extraBounce"] ?? 0.0
            return 1.2 + extraBounce * 1.0
        default:
            return 1.0
        }
    }

    private func generateCurvePoints(for slot: ComparisonSlot, count: Int, timeScale: Double) -> [CGPoint] {
        (0..<count).map { i in
            let normalizedX = Double(i) / Double(count - 1)
            let t = normalizedX * timeScale
            let y = curveValue(at: t, for: slot)
            return CGPoint(x: normalizedX, y: y)
        }
    }

    private func curveValue(at t: Double, for slot: ComparisonSlot) -> Double {
        let curve = slot.curve
        let params = slot.parameterValues

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
            let extraBounce = params["extraBounce"] ?? 0.0
            return springValue(t: t, bounce: extraBounce * 1.2)
        case .spring:
            let bounce = params["bounce"] ?? 0.3
            return springValue(t: t, bounce: bounce)
        case .snappy:
            let extraBounce = params["extraBounce"] ?? 0.0
            return springValue(t: t, bounce: 0.2 + extraBounce * 1.0)
        case .bouncy:
            let extraBounce = params["extraBounce"] ?? 0.0
            return springValue(t: t, bounce: 0.5 + extraBounce * 0.9)
        case .interpolatingSpring:
            let stiffness = params["stiffness"] ?? 170.0
            let damping = params["damping"] ?? 15.0
            return interpolatingSpringValue(t: t, stiffness: stiffness, damping: damping)
        case .interactiveSpring:
            let response = params["response"] ?? 0.4
            let dampingFraction = params["dampingFraction"] ?? 0.7
            return interactiveSpringValue(t: t, response: response, dampingFraction: dampingFraction)
        }
    }

    private func drawAxes(context: GraphicsContext, rect: CGRect, minY: Double, maxY: Double) {
        let range = maxY - minY
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

        context.draw(
            Text("0").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.minX - 8, y: y0Screen)
        )

        context.draw(
            Text("1").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.minX - 8, y: y1Screen)
        )

        context.draw(
            Text("t").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.maxX + 6, y: y0Screen + 8)
        )

        // Dashed line at y=1
        var refPath = Path()
        refPath.move(to: CGPoint(x: rect.minX, y: y1Screen))
        refPath.addLine(to: CGPoint(x: rect.maxX, y: y1Screen))
        context.stroke(
            refPath,
            with: .color(Color.gray.opacity(0.2)),
            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
        )
    }

    private func drawCurve(context: GraphicsContext, rect: CGRect, points: [CGPoint], minY: Double, maxY: Double, color: Color) {
        let range = maxY - minY

        var curvePath = Path()
        for (index, point) in points.enumerated() {
            let x = rect.minX + point.x * rect.width
            let normalizedY = (point.y - minY) / range
            let y = rect.maxY - normalizedY * rect.height

            if index == 0 {
                curvePath.move(to: CGPoint(x: x, y: y))
            } else {
                curvePath.addLine(to: CGPoint(x: x, y: y))
            }
        }

        context.stroke(curvePath, with: .color(color), lineWidth: 2.5)
    }

    // MARK: - Curve Math Functions

    private func cubicBezier(t: Double, p1: CGPoint, p2: CGPoint) -> Double {
        let cx = 3.0 * p1.x
        let bx = 3.0 * (p2.x - p1.x) - cx
        let ax = 1.0 - cx - bx

        let cy = 3.0 * p1.y
        let by = 3.0 * (p2.y - p1.y) - cy
        let ay = 1.0 - cy - by

        var tCurve = t
        for _ in 0..<8 {
            let xCurrent = ((ax * tCurve + bx) * tCurve + cx) * tCurve
            let xDerivative = (3.0 * ax * tCurve + 2.0 * bx) * tCurve + cx
            if abs(xDerivative) < 1e-6 { break }
            tCurve = tCurve - (xCurrent - t) / xDerivative
        }

        return ((ay * tCurve + by) * tCurve + cy) * tCurve
    }

    private func springValue(t: Double, bounce: Double) -> Double {
        if t <= 0.0 { return 0.0 }

        let clampedBounce = min(bounce, 1.4)
        let dampingRatio = max(0.1, 1.0 - clampedBounce * 0.85)
        let omega = 12.0

        if dampingRatio >= 1.0 {
            let decay = exp(-omega * t)
            return 1.0 - decay * (1.0 + omega * t)
        } else {
            let omegaD = omega * sqrt(1.0 - dampingRatio * dampingRatio)
            let decay = exp(-dampingRatio * omega * t)
            return 1.0 - decay * (cos(omegaD * t) + (dampingRatio * omega / omegaD) * sin(omegaD * t))
        }
    }

    private func interpolatingSpringValue(t: Double, stiffness: Double, damping: Double) -> Double {
        if t <= 0.0 { return 0.0 }

        let omega = sqrt(stiffness)
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

    private func interactiveSpringValue(t: Double, response: Double, dampingFraction: Double) -> Double {
        if t <= 0.0 { return 0.0 }

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
