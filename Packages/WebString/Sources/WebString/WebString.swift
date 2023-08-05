//
//  WebString.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 5/8/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import HTML2Markdown
import SwiftUI

extension String {
    var markdownParsingOptions: AttributedString.MarkdownParsingOptions {
        .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
    }

    func parseHTMLToMarkdown() throws -> String {
        let htmlDOM = try HTMLParser().parse(html: self)
        return htmlDOM.toMarkdown()
    }

    /// An attributed string that represents the HTML of this string.
    @available(*, deprecated, renamed: "AttributedString(html:)")
    public var attributedHTML: AttributedString {
        do {
            return try AttributedString(markdown: parseHTMLToMarkdown(), options: markdownParsingOptions)
        } catch {
            return AttributedString(stringLiteral: self)
        }
    }

    /// The markdown syntax for this string.
    public var markdown: String {
        do {
            return try parseHTMLToMarkdown()
        } catch {
            return self
        }
    }

    /// The plain text contents of this string, discarding HTML syntax nodes.
    public var plainTextContent: String {
        do {
            let attrString = try NSAttributedString(markdown: parseHTMLToMarkdown(), options: markdownParsingOptions)
            return attrString.string
        } catch {
            return self
        }
    }
}

public extension AttributedString {
    init(html: String) {
        do {
            self = try AttributedString(markdown: html.parseHTMLToMarkdown(), options: html.markdownParsingOptions)
        } catch {
            self = AttributedString(stringLiteral: html)
        }
    }
}
