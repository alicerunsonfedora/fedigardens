//
//  ComposerFlow.swift
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
import FlowKit
import Foundation

public actor ComposerFlow {
    public enum State: Equatable, Hashable {
        case initial
        case editing(ComposerDraft)
        case published
        case errored(ComposerFlowError)
    }

    public enum Event {
        case startDraft(ComposerDraft)
        case updateContent(String)
        case updatePoll(ComposerDraftPoll)
        case updateParticipants(String)
        case updateLocalizationCode(String)
        case updateContentWarning(Bool, message: String)
        case updateVisibility(PostVisibility)
        case publish
        case reset
    }

    public var state: State { internalState }
    public var stateSubscribers = [((State) -> Void)]()

    var characterLimit: Int
    var internalState: State = .initial {
        didSet {
            for callback in stateSubscribers {
                callback(internalState)
            }
        }
    }
    var networkProvider: Alice

    public init(characterLimit: Int, provider: Alice) {
        self.characterLimit = characterLimit
        self.networkProvider = provider
    }

}

extension ComposerFlow: StatefulFlowProviding {
    public func emit(_ event: Event) async {

    }
}
