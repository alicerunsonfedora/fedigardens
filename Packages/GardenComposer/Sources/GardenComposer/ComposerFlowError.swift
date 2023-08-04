//
//  ComposerFlowError.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/8/23.
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

/// A representation of the various errors the ``ComposerFlow`` can encounter.
public enum ComposerFlowError: LocalizedError {
    /// A draft wasn't supplied to the flow.
    case noDraftSupplied

    /// The current contents of the draft exceed the imposed character limit.
    case exceedsCharacterLimit

    /// An error occurred server-side.
    case mastodonError(FetchError)

    /// The current flow state and event being emitted doesn't match the expected chain of events.
    case unsupportedEventDispatch
}

extension ComposerFlowError: Equatable, Hashable {}

extension FetchError: Equatable, Hashable {
    public static func == (lhs: FetchError, rhs: FetchError) -> Bool {
        lhs.description == rhs.description
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}
