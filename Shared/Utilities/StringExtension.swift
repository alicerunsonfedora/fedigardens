//
//  StringExtension.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 11/2/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

extension String {
    /// Returns a plain-text form of an HTML-formatted string.
    ///
    /// This method returns asynchronously due to the nature of how ``NSAttributedString`` renders HTML with respect
    /// to threads.
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
}
