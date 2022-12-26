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
    func uriToURL() -> URL? {
        let modifiedURL = uri
            .replacingOccurrences(of: "/users/", with: "/@")
            .replacingOccurrences(of: "/statuses", with: "")
            .replacingOccurrences(of: "/activity", with: "")
        return URL(string: modifiedURL)
    }
}
