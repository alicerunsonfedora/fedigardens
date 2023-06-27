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

/// A structure that describes the context of a current intervention authorization.
public struct InterventionAuthorizationContext: Identifiable, Hashable {

    /// The context's unique identifier.
    public var id = UUID()

    /// The allowed amount of time before a reintervention can occur.
    public var allowedTimeInterval: TimeInterval

    /// The number of items that can be fetched.
    public var allowedFetchSize: Int

    /// Creates an authorization context.
    /// - Parameter id: The unique identifier for this context.
    /// - Parameter allowedTimeInterval: The amount of time that is allowed before another intervention occurs.
    /// - Parameter allowedFetchSize: The number of items that can be fetched in this context before another
    ///   intervention occurs.
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

    /// A default case with no time allowed and a fetch size of zero.
    public static var `default`: InterventionAuthorizationContext {
        .init(allowedTimeInterval: 0, allowedFetchSize: 0)
    }
}

private struct InterventionAuthorizationContextKey: EnvironmentKey {
    static let defaultValue: InterventionAuthorizationContext = .default
}

extension EnvironmentValues {
    /// The current intervention authorization context.
    ///
    /// This is commonly used to determine what can be performed without intervention, or if specific actions such as
    /// fetching more data is permitted given the current authorization.
    ///
    /// - SeeAlso: ``InterventionAuthorizationContext``
    public var interventionAuthorization: InterventionAuthorizationContext {
        get { self[InterventionAuthorizationContextKey.self] }
        set { self[InterventionAuthorizationContextKey.self] = newValue }
    }
}
