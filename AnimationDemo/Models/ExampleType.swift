//
//  ExampleType.swift
//  AnimationDemo
//

import SwiftUI

enum ExampleType: String, CaseIterable, Identifiable {
    case toggleSwitch = "Toggle Switch"
    case floatingButton = "Floating Button"
    case dragRelease = "Drag & Release"
    case heartReaction = "Heart Reaction"
    case pullToRefresh = "Pull to Refresh"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .toggleSwitch: return "switch.2"
        case .floatingButton: return "plus.circle.fill"
        case .dragRelease: return "hand.draw"
        case .heartReaction: return "heart.fill"
        case .pullToRefresh: return "arrow.down.circle"
        }
    }

    var description: String {
        switch self {
        case .toggleSwitch: return "Tap to toggle on/off with spring animation"
        case .floatingButton: return "Tap to expand menu with staggered springs"
        case .dragRelease: return "Drag anywhere, release to spring back"
        case .heartReaction: return "Tap to show a bouncing heart"
        case .pullToRefresh: return "Pull down to trigger refresh animation"
        }
    }

    var accentColor: Color {
        switch self {
        case .toggleSwitch: return .green
        case .floatingButton: return .orange
        case .dragRelease: return .purple
        case .heartReaction: return .red
        case .pullToRefresh: return .blue
        }
    }

    var codeSnippet: String {
        switch self {
        case .toggleSwitch:
            return """
            withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                isOn.toggle()
            }
            """
        case .floatingButton:
            return """
            withAnimation(.spring(duration: 0.4, bounce: 0.3).delay(Double(index) * 0.05)) {
                isExpanded.toggle()
            }
            """
        case .dragRelease:
            return """
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                dragOffset = .zero
            }
            """
        case .heartReaction:
            return """
            withAnimation(.spring(duration: 0.4, bounce: 0.6)) {
                heartScale = 1.3
            }
            """
        case .pullToRefresh:
            return """
            withAnimation(.interpolatingSpring(stiffness: 150, damping: 12)) {
                pullOffset = 0
            }
            """
        }
    }
}
