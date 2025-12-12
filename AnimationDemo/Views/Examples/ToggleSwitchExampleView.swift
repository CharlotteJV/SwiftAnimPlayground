//
//  ToggleSwitchExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct ToggleSwitchExampleView: View {
    @State private var isOn = false
    @State private var duration: Double = 0.4
    @State private var bounce: Double = 0.3

    private let example = ExampleType.toggleSwitch

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
                Capsule()
                    .fill(isOn ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 200, height: 110)

                Circle()
                    .fill(.white)
                    .frame(width: 90, height: 90)
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                    .offset(x: isOn ? 45 : -45)
            }
            .onTapGesture {
                withAnimation(.spring(duration: duration, bounce: bounce)) {
                    isOn.toggle()
                }
            }
        }
    }
}

#Preview {
    ToggleSwitchExampleView()
}
