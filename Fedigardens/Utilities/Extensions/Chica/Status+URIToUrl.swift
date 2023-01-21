//
//  Status+URIToUrl.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/24/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import Alice

extension Status {
    enum QuoteSource: String {
        case fedigardens = "Fedigardens"
        case icecubes = "Ice Cubes"
        case retoot = "Re: Toot"
        case fallback = "Generic link"
    }

    static let mentionRegex = /\@([a-zA-Z0-9\_]+)\@([a-zA-Z0-9\_\-.]+)/

    static let standardQuoteRegex = /(💬)\: (https\:\/\/[a-zA-Z.0-9\-\_]+)\/@[a-zA-Z0-9]+\/(\d+)/
    static let icecubesQuoteRegex = /From\: @([a-zA-Z0-9]+)\n(https\:\/\/[a-zA-Z.0-9\-\_]+)\/@[a-zA-Z0-9]+\/(\d+)/
    static let retootQuoteRegex = /Quoting @([a-zA-Z0-9]+)\: (https\:\/\/[a-zA-Z.0-9\-\_]+)\/@[a-zA-Z0-9]+\/(\d+)/
    static let fallbackQuoteRegex = /(https\:\/\/[a-zA-Z.0-9\-\_]+)\/@[a-zA-Z0-9]+\/(\d+)/

    func originalAuthor() -> Account {
        return reblog?.account ?? account
    }

    func uriToURL() -> URL? {
        let modifiedURL = uri
            .replacingOccurrences(of: "/users/", with: "/@")
            .replacingOccurrences(of: "/statuses", with: "")
            .replacingOccurrences(of: "/activity", with: "")
        return URL(string: modifiedURL)
    }

    /// Returns the ID of a quoted reply using the custom quote format.
    func quotedReply() -> (QuoteSource, String, String)? { // swiftlint:disable:this large_tuple
        if let match = content.plainTextContents().firstMatch(of: Status.standardQuoteRegex) {
            let (_, _, requestURL, requestID) = match.output
            return (.fedigardens, String(requestURL), String(requestID))
        }
        if let match = content.plainTextContents().firstMatch(of: Status.icecubesQuoteRegex) {
            let (_, _, requestURL, requestID) = match.output
            return (.icecubes, String(requestURL), String(requestID))
        }
        if let match = content.plainTextContents().firstMatch(of: Status.retootQuoteRegex) {
            let (_, _, requestURL, requestID) = match.output
            return (.retoot, String(requestURL), String(requestID))
        }
        if let match = content.plainTextContents().firstMatch(of: Status.fallbackQuoteRegex) {
            let (_, requestURL, requestID) = match.output
            return (.fallback, String(requestURL), String(requestID))
        }
        return nil
    }
}
