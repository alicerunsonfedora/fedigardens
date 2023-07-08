//
//  BagdedText.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 8/7/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

/// A piece of text representable as a badge.
///
/// Use this to display a piece of information in a badge-like manner:
/// ```swift
/// LabeledContent("Updates") {
/// BadgedText("New", filled: true)
///     .badgeColor(.red)
/// }
/// ```
///
/// By default, badged text will use the system accent color, if one is provided. This color can be changed using the
/// ``badgeColor(_:)`` modifier.
public struct BadgedText: View {
    var text: LocalizedStringKey
    var color: Color
    var filled: Bool = false

    /// Creates a piece of badged text.
    /// - Parameter text: The text that will be badged.
    /// - Parameter filled: Whether the badged text should be filled in. Defaults to false.
    public init(_ text: LocalizedStringKey, filled: Bool = false) {
        self.text = text
        self.color = .accentColor
        self.filled = filled
    }

    init(_ text: LocalizedStringKey, color: Color, filled: Bool = false) {
        self.text = text
        self.color = color
        self.filled = filled
    }

    public var body: some View {
        Text(text)
            .bold()
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundColor(filled ? .white : color)
            .overlay {
                Capsule()
                    .strokeBorder()
                    .foregroundColor(color)
            }
            .background(filled ? color : .white.opacity(0))
            .clipped()
            .clipShape(.capsule)
    }
}

public extension BadgedText {
    /// Sets the color of the badged text.
    ///
    /// For filled styles, this color will become the background color of the capsule. For unfilled styles, this color
    /// sets the text and stroke border colors.
    ///
    /// - Parameter color: The color to set the badged text to.
    func badgeColor(_ color: Color) -> Self {
        BadgedText(self.text, color: color, filled: self.filled)
    }
}

struct BadgedText_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VStack(spacing: 8) {
                BadgedText("Beta")
                    .badgeColor(.yellow)
                    .textCase(.uppercase)
                    .font(.caption)
                BadgedText("TestFlight", filled: true)
                    .badgeColor(.blue)
                    .font(.system(.largeTitle, design: .monospaced))
                BadgedText("New", filled: true)
                    .badgeColor(.red)
                    .textCase(.lowercase)
                    .font(.system(.body, design: .rounded))
            }
            .navigationTitle("Badged Text")
        }

    }
}
