//
//  HeartReactionExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct HeartReactionExampleView: View {
    @State private var isLiked = false
    @State private var heartScale: CGFloat = 1.0
    @State private var duration: Double = 0.4
    @State private var bounce: Double = 0.6

    private let example = ExampleType.heartReaction

    var body: some View {
        ExampleCardContainer(
            example: example,
            parameters: [
                .init(name: "duration", value: $duration, range: 0.1...1.0),
                .init(name: "bounce", value: $bounce, range: 0.0...1.0)
            ],
            animationCode: ".spring(duration: \(String(format: "%.2f", duration)), bounce: \(String(format: "%.2f", bounce)))"
        ) {
            ZStack {
                // Tap area background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 240, height: 240)

                // Heart icon
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 120))
                    .foregroundStyle(isLiked ? .red : .gray)
                    .scaleEffect(heartScale)
            }
            .onTapGesture {
                triggerHeartAnimation()
            }
        }
    }

    private func triggerHeartAnimation() {
        isLiked.toggle()

        if isLiked {
            // Bounce up
            withAnimation(.spring(duration: duration, bounce: bounce)) {
                heartScale = 1.3
            }

            // Return to normal
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.5) {
                withAnimation(.spring(duration: duration * 0.75, bounce: bounce * 0.6)) {
                    heartScale = 1.0
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                heartScale = 1.0
            }
        }
    }
}

#Preview {
    HeartReactionExampleView()
}
