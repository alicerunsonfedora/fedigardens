//
//  String+AttributedContent.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 11/2/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import SwiftUI
import HTML2Markdown

extension String {
    /// Returns a plain-text form of an HTML-formatted string.
    ///
    /// This method returns asynchronously due to the nature of how ``NSAttributedString`` renders HTML with respect
    /// to threads.
    @available(*, deprecated, message: "Use plainTextContents instead.")
    func toPlainText() async -> String {
        guard let strData = data(using: String.Encoding.utf8) else {
            return self
        }

        do {
            var string = try NSAttributedString(
                data: strData,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            ).string

            guard let newLineStripIdx = string.lastIndex(of: "\n") else { return string }
            string.remove(at: newLineStripIdx)
            return string
        } catch {
            print("Error converting to plain text: \(error.localizedDescription)")
            return self
        }
    }

    func attributedHTML() -> AttributedString {
        let dumbSelf = AttributedString(stringLiteral: self)
        do {
            let htmlDOM = try HTMLParser().parse(html: self)
            let markdown = htmlDOM.toMarkdown()
            return try AttributedString(
                markdown: markdown,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
        } catch {
            print("Error converting: \(error)")
            return dumbSelf
        }
    }

    func plainTextContents() -> String {
        do {
            let htmlDOM = try HTMLParser().parse(html: self)
            let markdown = htmlDOM.toMarkdown()
            let markdownStr = try NSAttributedString(
                markdown: markdown,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
            return markdownStr.string
        } catch {
            return self
        }
    }
}
