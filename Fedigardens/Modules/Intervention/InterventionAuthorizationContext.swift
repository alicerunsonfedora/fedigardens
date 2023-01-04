//
//  InterventionAuthorizationContext.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/3/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct InterventionAuthorizationContext: Identifiable {
    var id = UUID()
    var allowedTimeInterval: TimeInterval
    var allowedFetchSize: Int

    static var `default`: InterventionAuthorizationContext {
        .init(allowedTimeInterval: 0, allowedFetchSize: 0)
    }
}

private struct InterventionAuthorizationContextKey: EnvironmentKey {
    static let defaultValue: InterventionAuthorizationContext = .default
}

extension EnvironmentValues {
    var interventionAuthorization: InterventionAuthorizationContext {
        get { self[InterventionAuthorizationContextKey.self] }
        set { self[InterventionAuthorizationContextKey.self] = newValue }
    }
}
