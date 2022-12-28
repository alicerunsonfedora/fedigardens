//
//  Status+URIToUrl.swift
//  Gardens
//
//  Created by Marquis Kurt on 12/24/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import Chica

extension Status {
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
    func quotedReply() -> (String, String)? {
        let regex = /(💬)\: (https\:\/\/[a-zA-Z.0-9\-\_]+)\/@[a-zA-Z0-9]+\/(\d+)/
        if let match = content.plainTextContents().firstMatch(of: regex) {
            let (_, _, requestURL, requestID) = match.output
            return (String(requestURL), String(requestID))
        }
        return nil
    }
}
