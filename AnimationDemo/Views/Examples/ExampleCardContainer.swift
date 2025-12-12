//
//  ExampleCardContainer.swift
//  AnimationDemo
//

import SwiftUI

struct AnimationParameter: Identifiable {
    let id = UUID()
    let name: String
    var value: Binding<Double>
    let range: ClosedRange<Double>
}

struct ExampleCardContainer<Content: View>: View {
    let example: ExampleType
    let parameters: [AnimationParameter]
    let animationCode: String
    let content: () -> Content

    @State private var showCopied = false

    init(
        example: ExampleType,
        parameters: [AnimationParameter] = [],
        animationCode: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.example = example
        self.parameters = parameters
        self.animationCode = animationCode ?? example.codeSnippet
        self.content = content
    }

    var body: some View {
        VStack(spacing: 16) {
            // Title and description
            VStack(spacing: 6) {
                Text(example.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(example.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Interactive animation area
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(example.accentColor.opacity(0.05))
                )
                .clipped()

            // Parameter controls
            if !parameters.isEmpty {
                parameterControls
            }

            // Code preview
            codePreviewButton
        }
        .padding(24)
        .background(cardBackground)
    }

    private var parameterControls: some View {
        HStack(spacing: 24) {
            ForEach(parameters) { param in
                VStack(alignment: .leading, spacing: 4) {
                    Text(param.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        Slider(value: param.value, in: param.range)
                            .frame(width: 100)
                            .tint(example.accentColor)
                        Text(String(format: "%.2f", param.value.wrappedValue))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.primary)
                            .frame(width: 40)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.08))
        )
    }

    private var codePreviewButton: some View {
        Button {
            copyCode()
        } label: {
            HStack {
                Text(codeText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Image(systemName: showCopied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundStyle(showCopied ? .green : .secondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }

    private var codeText: String {
        showCopied ? "Copied!" : "withAnimation(\(animationCode)) { ... }"
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.background)
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(example.accentColor.opacity(0.15), lineWidth: 1)
            )
    }

    private func copyCode() {
        let fullCode = "withAnimation(\(animationCode)) {\n    // Your state change\n}"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(fullCode, forType: .string)
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopied = false
        }
    }
}
