//
//  UserProfileEnvironmentKey.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/25/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import Foundation
import SwiftUI

private struct UserProfileEnvironmentKey: EnvironmentKey {
    static let defaultValue: Account = MockData.profile!
}

extension EnvironmentValues {
    var userProfile: Account {
        get { self[UserProfileEnvironmentKey.self] }
        set { self[UserProfileEnvironmentKey.self] = newValue }
    }
}
