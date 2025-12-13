//
//  InfoButton.swift
//  AnimationDemo
//

import SwiftUI

struct InfoButton: View {
    let curve: AnimationCurve
    @Binding var parameterValues: [String: Double]

    @State private var showingPopover = false

    var body: some View {
        Button {
            showingPopover.toggle()
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showingPopover, arrowEdge: .trailing) {
            AnimationInfoPopover(
                curve: curve,
                parameterValues: $parameterValues
            )
        }
        .help("Learn about \(curve.rawValue)")
    }
}
