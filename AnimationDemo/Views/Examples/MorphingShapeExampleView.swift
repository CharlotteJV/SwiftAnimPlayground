//
//  MorphingShapeExampleView.swift
//  AnimationDemo
//

import SwiftUI

// MARK: - Morphable Shape

struct MorphableShape: Shape {
    var progress: Double // 0 = circle, 1 = square, 2 = star

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let pointCount = 120
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * 0.9

        let points = (0..<pointCount).map { i in
            interpolatedPoint(index: i, count: pointCount, center: center, radius: radius)
        }

        var path = Path()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }

    private func interpolatedPoint(index: Int, count: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let wrappedProgress = progress.truncatingRemainder(dividingBy: 3)
        let shapeIndex = Int(wrappedProgress)
        let fraction = wrappedProgress - Double(shapeIndex)

        let from = shapePoint(shapeIndex: shapeIndex, index: index, count: count, center: center, radius: radius)
        let to = shapePoint(shapeIndex: (shapeIndex + 1) % 3, index: index, count: count, center: center, radius: radius)

        return CGPoint(
            x: from.x + (to.x - from.x) * fraction,
            y: from.y + (to.y - from.y) * fraction
        )
    }

    private func shapePoint(shapeIndex: Int, index: Int, count: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = (Double(index) / Double(count)) * 2 * .pi - .pi / 2
        let cosAngle = CGFloat(cos(angle))
        let sinAngle = CGFloat(sin(angle))

        switch shapeIndex {
        case 0: // Circle
            return CGPoint(
                x: center.x + cosAngle * radius,
                y: center.y + sinAngle * radius
            )

        case 1: // Rounded square (superellipse approximation)
            let n: CGFloat = 4 // Higher = more square-like
            let r = radius / pow(pow(abs(cosAngle), n) + pow(abs(sinAngle), n), 1/n)
            return CGPoint(
                x: center.x + cosAngle * r,
                y: center.y + sinAngle * r
            )

        case 2: // 5-pointed star with straight edges
            let starPoints = 5
            let innerRadius = radius * 0.38

            // Calculate the 10 vertices of the star (5 outer points + 5 inner valleys)
            let vertexAngle = (2 * .pi) / Double(starPoints * 2)
            let normalizedAngle = angle + .pi / 2
            let wrappedAngle = normalizedAngle.truncatingRemainder(dividingBy: 2 * .pi)
            let positiveAngle = wrappedAngle < 0 ? wrappedAngle + 2 * .pi : wrappedAngle

            // Find which segment we're in and interpolate along the EDGE (not radius)
            let segmentIndex = Int(positiveAngle / vertexAngle)
            let segmentFraction = (positiveAngle - Double(segmentIndex) * vertexAngle) / vertexAngle

            // Get the two vertices that define this edge
            let vertex1Angle = Double(segmentIndex) * vertexAngle - .pi / 2
            let vertex2Angle = Double(segmentIndex + 1) * vertexAngle - .pi / 2
            let r1 = (segmentIndex % 2 == 0) ? radius : innerRadius
            let r2 = (segmentIndex % 2 == 0) ? innerRadius : radius

            let p1 = CGPoint(x: center.x + CGFloat(cos(vertex1Angle)) * r1,
                            y: center.y + CGFloat(sin(vertex1Angle)) * r1)
            let p2 = CGPoint(x: center.x + CGFloat(cos(vertex2Angle)) * r2,
                            y: center.y + CGFloat(sin(vertex2Angle)) * r2)

            // Interpolate along the straight edge
            return CGPoint(
                x: p1.x + (p2.x - p1.x) * segmentFraction,
                y: p1.y + (p2.y - p1.y) * segmentFraction
            )

        default:
            return center
        }
    }
}

// MARK: - Example View

struct MorphingShapeExampleView: View {
    @State private var morphProgress: Double = 0
    @State private var animationType: AnimationTypeOption = .smooth
    @State private var parameters: [String: Double] = ["duration": 0.4, "extraBounce": 0.2]

    private let example = ExampleType.morphingShape
    private let shapeNames = ["Circle", "Square", "Star"]

    private var currentShapeName: String {
        let index = Int(morphProgress.truncatingRemainder(dividingBy: 3))
        return shapeNames[index]
    }

    private var nextShapeName: String {
        let index = (Int(morphProgress.truncatingRemainder(dividingBy: 3)) + 1) % 3
        return shapeNames[index]
    }

    private var simplifiedCode: String {
        let animCode = animationType.codeString(with: parameters)
        return """
        import SwiftUI

        struct MorphableShape: Shape {
            var progress: Double  // 0 = circle, 1 = square, 2 = star

            var animatableData: Double {
                get { progress }
                set { progress = newValue }
            }

            func path(in rect: CGRect) -> Path {
                let pointCount = 120
                let center = CGPoint(x: rect.midX, y: rect.midY)
                let radius = min(rect.width, rect.height) / 2 * 0.9
                let points = (0..<pointCount).map { i in
                    interpolatedPoint(index: i, count: pointCount, center: center, radius: radius)
                }
                var path = Path()
                path.move(to: points[0])
                for point in points.dropFirst() { path.addLine(to: point) }
                path.closeSubpath()
                return path
            }

            private func interpolatedPoint(index: Int, count: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
                let wrappedProgress = progress.truncatingRemainder(dividingBy: 3)
                let shapeIndex = Int(wrappedProgress)
                let fraction = wrappedProgress - Double(shapeIndex)
                let from = shapePoint(shapeIndex: shapeIndex, index: index, count: count, center: center, radius: radius)
                let to = shapePoint(shapeIndex: (shapeIndex + 1) % 3, index: index, count: count, center: center, radius: radius)
                return CGPoint(x: from.x + (to.x - from.x) * fraction, y: from.y + (to.y - from.y) * fraction)
            }

            private func shapePoint(shapeIndex: Int, index: Int, count: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
                let angle = (Double(index) / Double(count)) * 2 * Double.pi - Double.pi / 2
                let cosA = CGFloat(cos(angle)), sinA = CGFloat(sin(angle))

                switch shapeIndex {
                case 0: // Circle
                    return CGPoint(x: center.x + cosA * radius, y: center.y + sinA * radius)
                case 1: // Rounded square (superellipse)
                    let n: CGFloat = 4
                    let r = radius / pow(pow(abs(cosA), n) + pow(abs(sinA), n), 1/n)
                    return CGPoint(x: center.x + cosA * r, y: center.y + sinA * r)
                case 2: // 5-pointed star with straight edges
                    let innerRadius = radius * 0.38
                    let vertexAngle = Double.pi / 5
                    let normAngle = (angle + Double.pi / 2).truncatingRemainder(dividingBy: 2 * Double.pi)
                    let posAngle = normAngle < 0 ? normAngle + 2 * Double.pi : normAngle
                    let segIdx = Int(posAngle / vertexAngle)
                    let frac = (posAngle - Double(segIdx) * vertexAngle) / vertexAngle
                    let a1 = Double(segIdx) * vertexAngle - Double.pi / 2
                    let a2 = Double(segIdx + 1) * vertexAngle - Double.pi / 2
                    let r1 = (segIdx % 2 == 0) ? radius : innerRadius
                    let r2 = (segIdx % 2 == 0) ? innerRadius : radius
                    let p1 = CGPoint(x: center.x + CGFloat(cos(a1)) * r1, y: center.y + CGFloat(sin(a1)) * r1)
                    let p2 = CGPoint(x: center.x + CGFloat(cos(a2)) * r2, y: center.y + CGFloat(sin(a2)) * r2)
                    return CGPoint(x: p1.x + (p2.x - p1.x) * frac, y: p1.y + (p2.y - p1.y) * frac)
                default:
                    return center
                }
            }
        }

        struct MorphingShapeView: View {
            @State private var progress: Double = 0

            var body: some View {
                VStack {
                    MorphableShape(progress: progress)
                        .fill(Color.purple.gradient)
                        .frame(width: 200, height: 200)

                    Button("Morph") {
                        withAnimation(\\(animCode)) {
                            progress += 1
                        }
                    }
                }
            }
        }

        #Preview {
            MorphingShapeView()
        }
        """
    }

    var body: some View {
        ExampleCardContainer(
            example: example,
            animationType: $animationType,
            parameters: $parameters,
            fullCode: simplifiedCode
        ) {
            VStack(spacing: 24) {
                Spacer()

                // Morphing shape
                MorphableShape(progress: morphProgress)
                    .fill(
                        LinearGradient(
                            colors: [example.accentColor, example.accentColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                    .shadow(color: example.accentColor.opacity(0.4), radius: 20, y: 10)

                // Current shape label
                Text(currentShapeName)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                // Morph button
                Button {
                    withAnimation(animationType.buildAnimation(with: parameters)) {
                        morphProgress += 1
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Morph to \(nextShapeName)")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(example.accentColor.gradient)
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 16)
            }
        }
    }
}

#Preview {
    MorphingShapeExampleView()
}
