//
//  HeroAnimationExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct HeroAnimationExampleView: View {
    @Namespace private var namespace
    @State private var isExpanded = false
    @State private var animationType: AnimationTypeOption = .spring
    @State private var parameters: [String: Double] = ["duration": 0.5, "bounce": 0.25]

    private let example = ExampleType.heroAnimation

    // Computed sizes based on state - these animate smoothly
    private var iconSize: CGFloat { isExpanded ? 64 : 28 }
    private var cardWidth: CGFloat { isExpanded ? 280 : 200 }
    private var cardHeight: CGFloat { isExpanded ? 300 : 80 }
    private var cornerRadius: CGFloat { isExpanded ? 24 : 16 }

    private var simplifiedCode: String {
        let animCode = animationType.codeString(with: parameters)
        return """
        import SwiftUI

        struct HeroAnimationView: View {
            @Namespace private var namespace
            @State private var isExpanded = false

            // Computed sizes animate smoothly
            var iconSize: CGFloat { isExpanded ? 64 : 28 }
            var cardWidth: CGFloat { isExpanded ? 280 : 200 }
            var cardHeight: CGFloat { isExpanded ? 300 : 80 }

            var body: some View {
                VStack {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: iconSize))
                            .foregroundStyle(.yellow)
                            .frame(width: iconSize, height: iconSize)
                            .matchedGeometryEffect(id: "icon", in: namespace)

                        if !isExpanded {
                            Text("Tap to expand")
                                .font(.headline)
                                .fixedSize()
                                .matchedGeometryEffect(id: "title", in: namespace)
                        }
                    }

                    if isExpanded {
                        Text("Tap to expand")
                            .font(.headline)
                            .fixedSize()
                            .matchedGeometryEffect(id: "title", in: namespace)
                            .padding(.top, 20)
                    }
                }
                .padding(20)
                .foregroundStyle(.white)
                .frame(width: cardWidth, height: cardHeight)
                .background(Color.mint.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture {
                    withAnimation(\(animCode)) {
                        isExpanded.toggle()
                    }
                }
            }
        }

        #Preview {
            HeroAnimationView()
        }
        """
    }

    var body: some View {
        ExampleCardContainer(
            example: example,
            animationType: $animationType,
            parameters: $parameters,
            fullCode: simplifiedCode
        ) {
            VStack {
                // Icon and title row
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: iconSize))
                        .foregroundStyle(.yellow)
                        .frame(width: iconSize, height: iconSize)
                        .matchedGeometryEffect(id: "icon", in: namespace)

                    if !isExpanded {
                        Text("Tap to expand")
                            .font(.headline)
                            .fixedSize()
                            .matchedGeometryEffect(id: "title", in: namespace)
                    }
                }

                if isExpanded {
                    Text("Tap to expand")
                        .font(.headline)
                        .fixedSize()
                        .matchedGeometryEffect(id: "title", in: namespace)
                        .padding(.top, 20)

                    Text("The icon scales up and the title\nmoves below it smoothly")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .opacity(0.8)
                        .padding(.top, 8)

                    Spacer()

                    Text("Tap to collapse")
                        .font(.caption)
                        .opacity(0.6)
                }
            }
            .padding(20)
            .foregroundStyle(.white)
            .frame(width: cardWidth, height: cardHeight)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(example.accentColor.gradient)
            )
            .shadow(color: example.accentColor.opacity(0.4), radius: isExpanded ? 20 : 12, y: isExpanded ? 10 : 6)
            .onTapGesture {
                withAnimation(animationType.buildAnimation(with: parameters)) {
                    isExpanded.toggle()
                }
            }
        }
    }
}

#Preview {
    HeroAnimationExampleView()
}
