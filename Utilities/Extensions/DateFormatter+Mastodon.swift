//
//  DateFormatter+Mastodon.swift
//  Gardens
//
//  Created by Marquis Kurt on 11/2/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

extension DateFormatter {
    /// A date formatter that can parse dates written for Mastodon posts.
    ///
    /// Due to the unusual nature of Mastodon's date format (even though it follows ISO-8601), a new formatter must
    /// be used to parse these dates correctly.
    /// - Format: `yyyy-MM-dd'T'HH:mm:ss.SZ`
    static var mastodon: DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        format.timeZone = .init(abbreviation: "UTC")
        format.locale = .init(identifier: "en_US_POSIX")
        return format
    }
}
