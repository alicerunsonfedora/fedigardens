// 
//  AuthModuleEnvironmentKey.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/16/23.
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

private struct AuthModuleEnvironmentKey: EnvironmentKey {
    static let defaultValue: AuthenticationModule = .init()
}

extension EnvironmentValues {
    var authentication: AuthenticationModule {
        get { self[AuthModuleEnvironmentKey.self] }
        set { self[AuthModuleEnvironmentKey.self] = newValue }
    }
}
