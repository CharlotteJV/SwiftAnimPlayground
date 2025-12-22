//
//  CodePreviewSheet.swift
//  AnimationDemo
//

import SwiftUI

struct CodePreviewSheet: View {
    let title: String
    let code: String
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))

            // Code view
            ScrollView([.horizontal, .vertical]) {
                SyntaxHighlightedCode(code: code)
                    .textSelection(.enabled)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(red: 0.14, green: 0.14, blue: 0.16))

            // Footer with copy button
            HStack {
                Text("Paste this into a new SwiftUI file to try it out")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(code, forType: .string)
                    copied = true
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(2))
                        copied = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        Text(copied ? "Copied!" : "Copy Code")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(copied ? Color.green : Color.accentColor)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 700, height: 550)
    }
}

// MARK: - Syntax Highlighting

struct SyntaxHighlightedCode: View {
    let code: String

    // Colors inspired by Xcode's dark theme
    private let keywordColor = Color(red: 0.99, green: 0.42, blue: 0.62)      // Pink - keywords
    private let typeColor = Color(red: 0.35, green: 0.76, blue: 0.78)         // Cyan - types
    private let stringColor = Color(red: 0.99, green: 0.56, blue: 0.37)       // Orange - strings
    private let numberColor = Color(red: 0.82, green: 0.78, blue: 0.50)       // Yellow - numbers
    private let commentColor = Color(red: 0.45, green: 0.50, blue: 0.55)      // Gray - comments
    private let propertyColor = Color(red: 0.63, green: 0.51, blue: 0.86)     // Purple - properties
    private let defaultColor = Color(red: 0.90, green: 0.90, blue: 0.92)      // White - default

    private let keywords = [
        "struct", "var", "let", "func", "if", "else", "for", "in", "return",
        "private", "public", "static", "class", "enum", "case", "switch",
        "import", "true", "false", "nil", "self", "some", "@State", "@Binding",
        "@Published", "@ObservedObject", "@StateObject", "@Environment"
    ]

    private let types = [
        "View", "Body", "some", "Color", "CGFloat", "Double", "Int", "String",
        "Bool", "CGSize", "CGPoint", "Animation", "Image", "Text", "VStack",
        "HStack", "ZStack", "Button", "Spacer", "Circle", "RoundedRectangle",
        "Capsule", "ForEach", "Group", "GeometryReader", "ScrollView",
        "DragGesture", "State", "Binding", "UUID", "Identifiable"
    ]

    var body: some View {
        Text(attributedCode)
            .font(.system(size: 13, weight: .regular, design: .monospaced))
            .lineSpacing(4)
    }

    private var attributedCode: AttributedString {
        var result = AttributedString()
        let lines = code.split(separator: "\n", omittingEmptySubsequences: false)

        for (lineIndex, line) in lines.enumerated() {
            let lineStr = String(line)

            // Check if line is a comment
            let trimmed = lineStr.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("//") {
                var commentAttr = AttributedString(lineStr)
                commentAttr.foregroundColor = commentColor
                result += commentAttr
            } else {
                result += highlightLine(lineStr)
            }

            if lineIndex < lines.count - 1 {
                result += AttributedString("\n")
            }
        }

        return result
    }

    private func highlightLine(_ line: String) -> AttributedString {
        var result = AttributedString()
        var remaining = line[...]
        var inString = false
        var stringChar: Character = "\""

        while !remaining.isEmpty {
            // Handle strings
            if !inString && (remaining.first == "\"" || remaining.first == "'") {
                stringChar = remaining.first!
                inString = true
                let startIndex = remaining.startIndex

                remaining = remaining.dropFirst()
                while !remaining.isEmpty {
                    let char = remaining.first!
                    remaining = remaining.dropFirst()
                    if char == stringChar && (remaining.isEmpty || line[line.index(before: remaining.startIndex)] != "\\") {
                        break
                    }
                }

                let stringContent = String(line[startIndex..<remaining.startIndex])
                var attr = AttributedString(stringContent)
                attr.foregroundColor = stringColor
                result += attr
                inString = false
                continue
            }

            // Try to match a token
            if let match = matchToken(in: remaining) {
                let token = String(remaining.prefix(match.length))
                var attr = AttributedString(token)
                attr.foregroundColor = match.color
                result += attr
                remaining = remaining.dropFirst(match.length)
                continue
            }

            // Default: single character
            var attr = AttributedString(String(remaining.first!))
            attr.foregroundColor = defaultColor
            result += attr
            remaining = remaining.dropFirst()
        }

        return result
    }

    private struct TokenMatch {
        let length: Int
        let color: Color
    }

    private func matchToken(in text: Substring) -> TokenMatch? {
        // Check for numbers
        if let first = text.first, first.isNumber || (first == "." && text.dropFirst().first?.isNumber == true) {
            var length = 0
            var hasDecimal = first == "."
            for char in text {
                if char.isNumber {
                    length += 1
                } else if char == "." && !hasDecimal {
                    hasDecimal = true
                    length += 1
                } else {
                    break
                }
            }
            if length > 0 {
                return TokenMatch(length: length, color: numberColor)
            }
        }

        // Check for keywords and types (must be followed by non-alphanumeric)
        for keyword in keywords {
            if text.hasPrefix(keyword) {
                let afterIndex = text.index(text.startIndex, offsetBy: keyword.count, limitedBy: text.endIndex)
                if afterIndex == text.endIndex || !text[afterIndex!].isLetter && !text[afterIndex!].isNumber && text[afterIndex!] != "_" {
                    return TokenMatch(length: keyword.count, color: keywordColor)
                }
            }
        }

        for type in types {
            if text.hasPrefix(type) {
                let afterIndex = text.index(text.startIndex, offsetBy: type.count, limitedBy: text.endIndex)
                if afterIndex == text.endIndex || !text[afterIndex!].isLetter && !text[afterIndex!].isNumber && text[afterIndex!] != "_" {
                    return TokenMatch(length: type.count, color: typeColor)
                }
            }
        }

        // Check for property/method access (after .)
        if text.first == "." {
            var length = 1
            for char in text.dropFirst() {
                if char.isLetter || char.isNumber || char == "_" {
                    length += 1
                } else {
                    break
                }
            }
            if length > 1 {
                return TokenMatch(length: length, color: propertyColor)
            }
        }

        return nil
    }
}

struct ViewCodeButton: View {
    let title: String
    let code: String
    @State private var showingSheet = false

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                Text("View Code")
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingSheet) {
            CodePreviewSheet(title: title, code: code)
        }
    }
}

#Preview {
    CodePreviewSheet(
        title: "Toggle Switch Example",
        code: """
        struct ToggleSwitchView: View {
            @State private var isOn = false

            var body: some View {
                ZStack {
                    Capsule()
                        .fill(isOn ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 60, height: 34)

                    Circle()
                        .fill(.white)
                        .frame(width: 28, height: 28)
                        .offset(x: isOn ? 13 : -13)
                }
                .onTapGesture {
                    withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                        isOn.toggle()
                    }
                }
            }
        }
        """
    )
}
