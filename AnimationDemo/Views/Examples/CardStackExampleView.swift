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

/// A card that's animating out of the stack
struct DismissingCard: Identifiable {
    let id: UUID
    let card: SwipeCard
    let offset: CGSize
    let rotation: Double
    let targetOffset: CGSize
    let targetRotation: Double
    let velocity: CGFloat
}

struct CardStackExampleView: View {
    @State private var cards: [SwipeCard] = CardStackExampleView.generateCards()
    @State private var dismissingCards: [DismissingCard] = []
    @State private var topCardDragProgress: CGFloat = 0 // 0 = no drag, 1 = at threshold

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
        import SwiftUI

        struct Card: Identifiable {
            let id = UUID()
            let color: Color
            let title: String
        }

        struct CardStackView: View {
            @State private var cards: [Card] = [
                Card(color: .pink, title: "First"),
                Card(color: .blue, title: "Second"),
                Card(color: .green, title: "Third")
            ]
            @State private var dragProgress: CGFloat = 0

            var body: some View {
                ZStack {
                    ForEach(Array(cards.prefix(3).enumerated().reversed()), id: \\.element.id) { index, card in
                        let stackOffset = CGFloat(index) * (1 - dragProgress)

                        CardView(card: card, isTop: index == 0, onDragChanged: { progress in
                            withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.8)) {
                                dragProgress = max(progress, 0)
                            }
                            if progress < 0 { // Snap-back signal
                                withAnimation(\(snapBackCode)) { dragProgress = 0 }
                            }
                        }, onDismiss: {
                            dragProgress = 0
                            cards.removeAll { $0.id == card.id }
                        })
                        .offset(y: stackOffset * 8)
                        .scaleEffect(1 - stackOffset * 0.05)
                    }
                }
            }
        }

        struct CardView: View {
            let card: Card
            let isTop: Bool
            var onDragChanged: (CGFloat) -> Void
            var onDismiss: () -> Void

            @State private var offset: CGSize = .zero

            var body: some View {
                RoundedRectangle(cornerRadius: 20)
                    .fill(card.color.gradient)
                    .frame(width: 180, height: 200)
                    .overlay(Text(card.title).foregroundStyle(.white))
                    .offset(offset)
                    .rotationEffect(.degrees(Double(offset.width) / 20))
                    .gesture(isTop ? DragGesture()
                        .onChanged { value in
                            offset = value.translation
                            onDragChanged(abs(offset.width) / 150)
                        }
                        .onEnded { value in
                            let velocity = abs(value.velocity.width) / 800
                            if abs(offset.width) > 150 {
                                withAnimation(\(dismissCode)) {
                                    offset.width = offset.width > 0 ? 800 : -800
                                }
                                onDismiss()
                            } else {
                                onDragChanged(-1) // Signal snap-back
                                withAnimation(\(snapBackCode)) {
                                    offset = .zero
                                }
                            }
                        } : nil
                    )
            }
        }

        #Preview {
            CardStackView()
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
                    // Cards animating out (behind the stack)
                    ForEach(dismissingCards) { dismissing in
                        DismissingCardView(
                            dismissingCard: dismissing,
                            dismissAnimationType: dismissAnimationType,
                            dismissParameters: dismissParameters
                        )
                        .zIndex(0)
                    }

                    // Active card stack
                    ForEach(Array(cards.prefix(3).enumerated().reversed()), id: \.element.id) { index, card in
                        let effectiveIndex = CGFloat(index) * (1 - topCardDragProgress)

                        SwipeableCardView(
                            card: card,
                            isTop: index == 0,
                            snapBackAnimationType: snapBackAnimationType,
                            snapBackParameters: snapBackParameters,
                            dismissAnimationType: dismissAnimationType,
                            dismissParameters: dismissParameters,
                            onDragChanged: { progress in
                                if progress < 0 {
                                    // Snap-back signal: animate progress back to 0
                                    withAnimation(snapBackAnimationType.buildAnimation(with: snapBackParameters)) {
                                        topCardDragProgress = 0
                                    }
                                } else {
                                    // Smooth the drag progress with a light animation
                                    withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.8)) {
                                        topCardDragProgress = progress
                                    }
                                }
                            }
                        ) { offset, rotation, velocity in
                            topCardDragProgress = 0
                            dismissCard(card, offset: offset, rotation: rotation, velocity: velocity)
                        }
                        .offset(y: effectiveIndex * 8)
                        .scaleEffect(1.0 - effectiveIndex * 0.05)
                        .zIndex(Double(3 - index))
                    }

                    if cards.isEmpty && dismissingCards.isEmpty {
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

    private func dismissCard(_ card: SwipeCard, offset: CGSize, rotation: Double, velocity: CGFloat) {
        let direction: CGFloat = offset.width > 0 ? 1 : -1
        let dismissDistance: CGFloat = 800
        let targetOffset = CGSize(width: direction * dismissDistance, height: offset.height)
        let targetRotation = Double(direction * 30)

        // Create dismissing card with current position and velocity
        let dismissing = DismissingCard(
            id: card.id,
            card: card,
            offset: offset,
            rotation: rotation,
            targetOffset: targetOffset,
            targetRotation: targetRotation,
            velocity: velocity
        )

        // Remove from stack immediately (next card becomes interactive)
        cards.removeAll { $0.id == card.id }

        // Add to dismissing cards
        dismissingCards.append(dismissing)

        // Clean up after animation completes
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.8))
            dismissingCards.removeAll { $0.id == card.id }
        }
    }

    private func resetCards() {
        dismissingCards.removeAll()
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
    var onDragChanged: ((_ progress: CGFloat) -> Void)? = nil
    let onSwipe: (_ offset: CGSize, _ rotation: Double, _ velocity: CGFloat) -> Void

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0

    private let swipeThreshold: CGFloat = 150
    private let maxDistance: CGFloat = 300

    private var dragProgress: CGFloat {
        min(abs(offset.width) / maxDistance, 1.0)
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
                        // Report drag progress to parent for stack animation
                        onDragChanged?(min(abs(value.translation.width) / swipeThreshold, 1.0))
                    }
                    .onEnded { value in
                        if abs(value.translation.width) > swipeThreshold {
                            // Calculate velocity for the animation
                            let remainingDistance: CGFloat = 800 - abs(value.translation.width)
                            let velocity = abs(value.velocity.width) / remainingDistance

                            // Pass current state to parent - card will be removed immediately
                            onSwipe(offset, rotation, velocity)
                        } else {
                            // Snap back with animation (parent will animate progress back too)
                            withAnimation(snapBackAnimationType.buildAnimation(with: snapBackParameters)) {
                                offset = .zero
                                rotation = 0
                            }
                            onDragChanged?(-1) // Signal snap-back (negative value)
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

// MARK: - Dismissing Card View

struct DismissingCardView: View {
    let dismissingCard: DismissingCard
    let dismissAnimationType: AnimationTypeOption
    let dismissParameters: [String: Double]

    @State private var offset: CGSize
    @State private var rotation: Double
    @State private var opacity: Double = 1.0

    init(dismissingCard: DismissingCard, dismissAnimationType: AnimationTypeOption, dismissParameters: [String: Double]) {
        self.dismissingCard = dismissingCard
        self.dismissAnimationType = dismissAnimationType
        self.dismissParameters = dismissParameters
        // Start at the position where the card was released
        self._offset = State(initialValue: dismissingCard.offset)
        self._rotation = State(initialValue: dismissingCard.rotation)
    }

    private func dismissAnimation(velocity: CGFloat) -> Animation {
        if dismissAnimationType == .interpolatingSpring {
            let stiffness = dismissParameters["stiffness"] ?? 100
            let damping = dismissParameters["damping"] ?? 25
            return .interpolatingSpring(
                stiffness: stiffness,
                damping: damping,
                initialVelocity: velocity
            )
        } else {
            return dismissAnimationType.buildAnimation(with: dismissParameters)
        }
    }

    var body: some View {
        cardContent
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                // Animate to target position using the velocity from the swipe
                withAnimation(dismissAnimation(velocity: dismissingCard.velocity)) {
                    offset = dismissingCard.targetOffset
                    rotation = dismissingCard.targetRotation
                    opacity = 0.2
                }
            }
    }

    private var cardContent: some View {
        VStack(spacing: 12) {
            Image(systemName: dismissingCard.card.icon)
                .font(.system(size: 40))
                .foregroundStyle(.white)

            Text(dismissingCard.card.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 180, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(dismissingCard.card.color.gradient)
                .shadow(color: dismissingCard.card.color.opacity(0.4), radius: 12, y: 6)
        )
    }
}

#Preview {
    CardStackExampleView()
}
