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
import HTML2Markdown
import SwiftUI

extension String {
    @available(*, deprecated, message: "Use WebString to create attributed HTML strings.")
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

    @available(*, deprecated, message: "Use WebString to fetch markdown.")
    func markdown() -> String {
        let dumbSelf = self
        do {
            let htmlDOM = try HTMLParser().parse(html: self)
            return htmlDOM.toMarkdown()
        } catch {
            print("Error converting: \(error)")
            return dumbSelf
        }
    }

    @available(*, deprecated, message: "Use WebString to fetch plain text contents.")
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
