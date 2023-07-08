//
//  HashableType.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 8/7/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

/// A box type that allows keying in a dictionary from a hashable type.
///
/// This is used in conjunction with ``RecursiveNavigationStack`` to set recursive destinations.
public struct HashableType<T>: Hashable {
    public let base: T.Type

    public init(_ base: T.Type) {
        self.base = base
    }

    public static func == (lhs: HashableType, rhs: HashableType) -> Bool {
        lhs.base == rhs.base
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(base))
    }
}

public extension Dictionary {
    subscript<T>(key: T.Type) -> Value? where Key == HashableType<T> {
        get { return self[HashableType(key)] }
        set { self[HashableType(key)] = newValue }
    }
}
