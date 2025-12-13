//
//  GlobalControlsBar.swift
//  AnimationDemo
//

import SwiftUI

struct GlobalControlsBar: View {
    @Binding var animationType: AnimationType
    @Binding var demoShape: DemoShape
    @Binding var duration: Double
    @Binding var holdDuration: Double

    var body: some View {
        HStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Animation")
                    .font(.system(.caption, weight: .medium))
                    .foregroundStyle(.secondary)
                Picker("", selection: $animationType) {
                    ForEach(AnimationType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 240)
            }

            Divider()
                .frame(height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text("Shape")
                    .font(.system(.caption, weight: .medium))
                    .foregroundStyle(.secondary)
                Picker("", selection: $demoShape) {
                    ForEach(DemoShape.allCases, id: \.self) { shape in
                        Text(shape.rawValue).tag(shape)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }

            Divider()
                .frame(height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text("Duration")
                    .font(.system(.caption, weight: .medium))
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Slider(value: $duration, in: 0.2...1.5, step: 0.1)
                        .frame(width: 100)
                        .tint(.blue)
                    Text(String(format: "%.1fs", duration))
                        .font(.system(.subheadline))
                        .foregroundStyle(.primary)
                        .frame(width: 36)
                        .monospacedDigit()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Hold")
                    .font(.system(.caption, weight: .medium))
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Slider(value: $holdDuration, in: 0.5...3.0, step: 0.25)
                        .frame(width: 100)
                        .tint(.blue)
                    Text(String(format: "%.1fs", holdDuration))
                        .font(.system(.subheadline))
                        .foregroundStyle(.primary)
                        .frame(width: 36)
                        .monospacedDigit()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
    }
}
