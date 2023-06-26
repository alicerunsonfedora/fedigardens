//
//  InterventionContext.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 26/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

public struct InterventionAuthorizationContext: Identifiable, Hashable {
    public var id = UUID()
    public var allowedTimeInterval: TimeInterval
    public var allowedFetchSize: Int

    public init(id: UUID = UUID(), allowedTimeInterval: TimeInterval, allowedFetchSize: Int) {
        self.id = id
        self.allowedTimeInterval = allowedTimeInterval
        self.allowedFetchSize = allowedFetchSize
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(allowedTimeInterval)
        hasher.combine(allowedFetchSize)
    }

    public static var `default`: InterventionAuthorizationContext {
        .init(allowedTimeInterval: 0, allowedFetchSize: 0)
    }
}

private struct InterventionAuthorizationContextKey: EnvironmentKey {
    static let defaultValue: InterventionAuthorizationContext = .default
}

extension EnvironmentValues {
    public var interventionAuthorization: InterventionAuthorizationContext {
        get { self[InterventionAuthorizationContextKey.self] }
        set { self[InterventionAuthorizationContextKey.self] = newValue }
    }
}
