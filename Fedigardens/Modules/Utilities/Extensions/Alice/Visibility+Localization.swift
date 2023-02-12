//
//  Visibility+Localization.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/21/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import enum Alice.Visibility
import SwiftUI

extension Visibility {
    var localizedDescription: LocalizedStringKey {
        switch self {
        case .public:
            return "status.visibility.public"
        case .unlisted:
            return "status.visibility.unlisted"
        case .private:
            return "status.visibility.private"
        case .direct:
            return "status.visibility.direct"
        }
    }
}
