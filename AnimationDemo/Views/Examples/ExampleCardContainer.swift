//
//  ExampleCardContainer.swift
//  AnimationDemo
//

import SwiftUI

struct ExampleCardContainer<Content: View>: View {
    let example: ExampleType
    @Binding var animationType: AnimationTypeOption
    @Binding var parameters: [String: Double]
    var codeSuffix: String
    let content: () -> Content

    init(
        example: ExampleType,
        animationType: Binding<AnimationTypeOption>,
        parameters: Binding<[String: Double]>,
        codeSuffix: String = "",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.example = example
        self._animationType = animationType
        self._parameters = parameters
        self.codeSuffix = codeSuffix
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

            // Interactive code editor
            InteractiveCodeEditor(
                animationType: $animationType,
                parameters: $parameters,
                accentColor: example.accentColor,
                suffix: codeSuffix
            )
        }
        .padding(24)
        .background(cardBackground)
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
}
