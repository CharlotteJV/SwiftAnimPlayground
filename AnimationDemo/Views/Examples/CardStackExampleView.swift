//
//  CardStackExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct SwipeCard: Identifiable {
    let id = UUID()
    let color: Color
    let icon: String
    let title: String
}

struct CardStackExampleView: View {
    @State private var cards: [SwipeCard] = CardStackExampleView.generateCards()

    // Animation 1: Snap back (when swipe doesn't reach threshold)
    @State private var snapBackAnimationType: AnimationTypeOption = .spring
    @State private var snapBackParameters: [String: Double] = ["duration": 0.4, "bounce": 0.4]

    // Animation 2: Dismiss (uses initialVelocity when interpolatingSpring)
    @State private var dismissAnimationType: AnimationTypeOption = .interpolatingSpring
    @State private var dismissParameters: [String: Double] = ["stiffness": 100, "damping": 25]

    private let example = ExampleType.cardStack

    private var simplifiedCode: String {
        let snapBackCode = snapBackAnimationType.codeString(with: snapBackParameters)
        let dismissCode: String
        if dismissAnimationType == .interpolatingSpring {
            let stiffness = dismissParameters["stiffness"] ?? 180
            let damping = dismissParameters["damping"] ?? 20
            dismissCode = ".interpolatingSpring(stiffness: \(String(format: "%.0f", stiffness)), damping: \(String(format: "%.0f", damping)), initialVelocity: velocity)"
        } else {
            dismissCode = dismissAnimationType.codeString(with: dismissParameters)
        }

        return """
        struct CardView: View {
            var body: some View {
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                    Text("Swipe Me")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(width: 180, height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.pink.gradient)
                )
            }
        }

        struct SwipeableCard: View {
            @State private var offset: CGSize = .zero
            @State private var rotation: Double = 0

            var body: some View {
                CardView()
                    .offset(offset)
                    .rotationEffect(.degrees(rotation))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation
                                rotation = Double(value.translation.width / 20)
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 100
                                if abs(value.translation.width) > threshold {
                                    // Dismiss (velocity used when interpolatingSpring)
                                    let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                                    let velocity = value.velocity.width / 1000

                                    withAnimation(\(dismissCode)) {
                                        offset.width = direction * 1000
                                        rotation = Double(direction * 30)
                                    }
                                } else {
                                    // Snap back
                                    withAnimation(\(snapBackCode)) {
                                        offset = .zero
                                        rotation = 0
                                    }
                                }
                            }
                    )
            }
        }
        """
    }

    var body: some View {
        VStack(spacing: 16) {
            // Title and description
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(example.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(example.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ViewCodeButton(title: "\(example.rawValue) Example", code: simplifiedCode)
            }

            // Interactive animation area
            VStack {
                Spacer()

                ZStack {
                    ForEach(Array(cards.prefix(3).enumerated().reversed()), id: \.element.id) { index, card in
                        SwipeableCardView(
                            card: card,
                            isTop: index == 0,
                            snapBackAnimationType: snapBackAnimationType,
                            snapBackParameters: snapBackParameters,
                            dismissAnimationType: dismissAnimationType,
                            dismissParameters: dismissParameters
                        ) {
                            removeCard(card)
                        }
                        .offset(y: CGFloat(index) * 8)
                        .scaleEffect(1.0 - CGFloat(index) * 0.05)
                        .zIndex(Double(3 - index))
                    }

                    if cards.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.green)
                            Text("All done!")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 220)

                Spacer()

                Button {
                    resetCards()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Cards")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(example.accentColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(example.accentColor.opacity(0.15))
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(example.accentColor.opacity(0.05))
            )
            .clipped()

            // Two animation code editors
            VStack(spacing: 12) {
                // Animation 1: Snap back
                VStack(alignment: .leading, spacing: 6) {
                    Text("Snap Back")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    InteractiveCodeEditor(
                        animationType: $snapBackAnimationType,
                        parameters: $snapBackParameters,
                        accentColor: .cyan
                    )
                }

                // Animation 2: Dismiss
                VStack(alignment: .leading, spacing: 6) {
                    Text("Dismiss")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    InteractiveCodeEditor(
                        animationType: $dismissAnimationType,
                        parameters: $dismissParameters,
                        accentColor: .pink,
                        fixedParameter: dismissAnimationType == .interpolatingSpring
                            ? FixedParameter(name: "initialVelocity", value: "velocity")
                            : nil
                    )
                }
            }
        }
        .padding(24)
    }

    private func removeCard(_ card: SwipeCard) {
        withAnimation(dismissAnimationType.buildAnimation(with: dismissParameters)) {
            cards.removeAll { $0.id == card.id }
        }
    }

    private func resetCards() {
        withAnimation(snapBackAnimationType.buildAnimation(with: snapBackParameters)) {
            cards = CardStackExampleView.generateCards()
        }
    }

    static func generateCards() -> [SwipeCard] {
        [
            SwipeCard(color: .pink, icon: "heart.fill", title: "Love"),
            SwipeCard(color: .blue, icon: "star.fill", title: "Star"),
            SwipeCard(color: .green, icon: "leaf.fill", title: "Nature"),
            SwipeCard(color: .orange, icon: "sun.max.fill", title: "Sunny"),
            SwipeCard(color: .purple, icon: "moon.fill", title: "Night")
        ]
    }
}

struct SwipeableCardView: View {
    let card: SwipeCard
    let isTop: Bool
    let snapBackAnimationType: AnimationTypeOption
    let snapBackParameters: [String: Double]
    let dismissAnimationType: AnimationTypeOption
    let dismissParameters: [String: Double]
    let onSwipe: () -> Void

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0

    private let swipeThreshold: CGFloat = 150
    private let maxDistance: CGFloat = 300
    private let dismissDistance: CGFloat = 800

    private var dragProgress: CGFloat {
        min(abs(offset.width) / maxDistance, 1.0)
    }

    private func dismissAnimation(velocity: CGFloat) -> Animation {
        if dismissAnimationType == .interpolatingSpring {
            // Use velocity with interpolatingSpring
            let stiffness = dismissParameters["stiffness"] ?? 180
            let damping = dismissParameters["damping"] ?? 20
            return .interpolatingSpring(
                stiffness: stiffness,
                damping: damping,
                initialVelocity: velocity
            )
        } else {
            // Use standard animation without velocity
            return dismissAnimationType.buildAnimation(with: dismissParameters)
        }
    }

    var body: some View {
        cardContent
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .opacity(1.0 - dragProgress * 0.8)
            .gesture(
                isTop ? DragGesture()
                    .onChanged { value in
                        offset = value.translation
                        rotation = Double(value.translation.width / 20)
                    }
                    .onEnded { value in
                        if abs(value.translation.width) > swipeThreshold {
                            // Dismiss
                            let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                            let remainingDistance = dismissDistance - abs(value.translation.width)
                            let velocity = abs(value.velocity.width) / remainingDistance

                            withAnimation(dismissAnimation(velocity: velocity)) {
                                offset.width = direction * dismissDistance
                                rotation = Double(direction * 30)
                            }

                            // Remove card after animation settles
                            Task { @MainActor in
                                try? await Task.sleep(for: .seconds(0.5))
                                onSwipe()
                            }
                        } else {
                            // Snap back
                            withAnimation(snapBackAnimationType.buildAnimation(with: snapBackParameters)) {
                                offset = .zero
                                rotation = 0
                            }
                        }
                    }
                : nil
            )
    }

    private var cardContent: some View {
        VStack(spacing: 12) {
            Image(systemName: card.icon)
                .font(.system(size: 40))
                .foregroundStyle(.white)

            Text(card.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 180, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(card.color.gradient)
                .shadow(color: card.color.opacity(0.4), radius: 12, y: 6)
        )
        .overlay(
            // Swipe indicators
            ZStack {
                // Like indicator
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.green)
                    .padding(12)
                    .background(Circle().fill(.white))
                    .opacity(offset.width > 30 ? min(Double(offset.width - 30) / 70, 1) : 0)
                    .offset(x: -50, y: -60)

                // Nope indicator
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.red)
                    .padding(12)
                    .background(Circle().fill(.white))
                    .opacity(offset.width < -30 ? min(Double(-offset.width - 30) / 70, 1) : 0)
                    .offset(x: 50, y: -60)
            }
        )
    }
}

#Preview {
    CardStackExampleView()
}
