//
//  AnimationInfoPopover.swift
//  AnimationDemo
//

import SwiftUI

struct AnimationInfoPopover: View {
    let curve: AnimationCurve
    @Binding var parameterValues: [String: Double]

    private var editableSpecs: [AnimationParameterSpec] {
        curve.editableParameterSpecs
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            description
            Divider()
            curveVisualization
            if !editableSpecs.isEmpty {
                interactiveSliders
            }
            Divider()
            parametersSection
        }
        .padding(16)
        .frame(width: 300)
    }

    private var header: some View {
        Text(curve.rawValue)
            .font(.headline)
            .fontWeight(.semibold)
    }

    private var description: some View {
        Text(curve.curveDescription)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var curveVisualization: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Timing Curve")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.tertiary)

            CurveGraphView(
                curve: curve,
                size: CGSize(width: 268, height: 140),
                bounce: parameterValues["bounce"] ?? 0.0,
                extraBounce: parameterValues["extraBounce"] ?? 0.0,
                stiffness: parameterValues["stiffness"] ?? 170.0,
                damping: parameterValues["damping"] ?? 15.0,
                response: parameterValues["response"] ?? 0.15,
                dampingFraction: parameterValues["dampingFraction"] ?? 0.86
            )
            .animation(.easeInOut(duration: 0.15), value: parameterValues)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.05))
            )

            HStack {
                Text("Time (t)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("Progress")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 4)
        }
    }

    private var interactiveSliders: some View {
        VStack(spacing: 10) {
            ForEach(editableSpecs) { spec in
                parameterSlider(for: spec)
            }
        }
        .padding(.vertical, 4)
    }

    private func parameterSlider(for spec: AnimationParameterSpec) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(spec.name)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)

                Spacer()

                Text(spec.formatValue(parameterValues[spec.id] ?? spec.defaultValue))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .trailing)
            }

            Slider(
                value: Binding(
                    get: { parameterValues[spec.id] ?? spec.defaultValue },
                    set: { parameterValues[spec.id] = $0 }
                ),
                in: spec.range,
                step: spec.step
            )
            .tint(.blue)
        }
    }

    private var parametersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Parameter Reference")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.tertiary)

            ForEach(curve.parameterSpecs) { spec in
                ParameterInfoRow(spec: spec)
            }
        }
    }
}

struct ParameterInfoRow: View {
    let spec: AnimationParameterSpec

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(spec.name)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)

                Text(spec.type)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.15))
                    )
            }

            Text(spec.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Text("Range: \(spec.rangeString)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Text("Default: \(spec.defaultValueString)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
