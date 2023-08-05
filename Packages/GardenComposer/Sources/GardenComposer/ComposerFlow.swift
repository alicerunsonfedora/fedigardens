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
import GardenSettings

/// A flow used to author and publish discussions.
///
/// This flow is typically used in conjunction with a view to create a composition window.
public actor ComposerFlow {
    /// A structure representing the character limit enforcement rules.
    public struct CharacterLimit {
        /// Whether the rule is enforced client-side.
        public var enforced: Bool

        /// The maximum number of characters the Mastodon instance accepts.
        public var maximumCharacters: Int

        /// Creates a character limit rule.
        public init(enforced: Bool = true, maximumCharacters: Int = 500) {
            self.enforced = enforced
            self.maximumCharacters = maximumCharacters
        }
    }

    /// A representation of the various states this flow can exist in.
    public enum State: Equatable, Hashable {
        /// The initial state.
        case initial

        /// A discussion is actively being edited.
        case editing(ComposerDraft)

        /// A discussion has been published to Mastodon.
        case published(Status)

        /// An error occurred in the flow.
        case errored(ComposerFlowError)
    }

    /// A representation of the various events that can occur.
    public enum Event {
        /// Starts writing a discussion from an initial draft.
        case startDraft(ComposerDraft)

        /// Updates the draft's primary content.
        case updateContent(String)

        /// Updates the draft's poll, adding one when necessary.
        case updatePoll(ComposerDraftPoll?)

        /// Updates the participants list of the current draft.
        case updateParticipants(String)

        /// Updates the draft's locale.
        case updateLocalizationCode(String)

        /// Updates the draft's content warning, marking the content as sensitive if necessary.
        case updateContentWarning(Bool, message: String)

        /// Updates the draft's visibility.
        case updateVisibility(PostVisibility)

        /// Publishes the current draft to Mastodon.
        case publish

        /// Resets the flow to its initial state.
        case reset
    }

    /// The current state of the flow.
    public var state: State { internalState }

    /// An array of subscribers currently subscribed to this flow.
    public var stateSubscribers = [((State) -> Void)]()

    var characterLimitProperties: CharacterLimit

    var internalState: State = .initial {
        didSet {
            for callback in stateSubscribers {
                callback(internalState)
            }
        }
    }
    var networkProvider: Alice

    /// Creates a new composer flow.
    /// - Parameter provider: The network provider that the flow makes network requests with.
    /// - Parameter maximumCharacters: The character limit the Mastodon instance enforces.
    public init(provider: Alice, limit: CharacterLimit) {
        self.characterLimitProperties = limit
        self.networkProvider = provider
    }

    func publishDraft() async -> State {
        guard case .editing(let composerDraft) = internalState else {
            return .errored(.noDraftSupplied)
        }
        if characterLimitProperties.enforced, composerDraft.count > characterLimitProperties.maximumCharacters {
            return .errored(.exceedsCharacterLimit(draft: composerDraft))
        }
        let parameters = composerDraft.discussionQueryParameters
        let requestMethod: Alice.Method = composerDraft.publishedStatusID == nil ? .post : .put
        let response: Alice.Response<Status> = await networkProvider.request(
            requestMethod,
            for: .statuses(id: composerDraft.publishedStatusID),
            params: parameters)
        switch response {
        case .success(let publishedStatus):
            return .published(publishedStatus)
        case .failure(let fetchError):
            return .errored(.mastodonError(fetchError, draft: composerDraft))
        }
    }
}

extension ComposerFlow: StatefulFlowProviding {
    /// Emits an event to the flow, updating the state as necessary.
    /// - parameter event: The event that will be emitted and acted upon.
    public func emit(_ event: Event) async { // swiftlint:disable:this cyclomatic_complexity
        switch (internalState, event) {
        case (.initial, .startDraft(let draft)):
            internalState = .editing(draft)
        case (.initial, .publish):
            internalState = .errored(.noDraftSupplied)
        case (.editing(var draft), .updateContent(let newMessage)):
            draft.content = newMessage
            internalState = .editing(draft)
        case (.editing(var draft), .updateParticipants(let newParticipants)):
            draft.mentions = newParticipants
            internalState = .editing(draft)
        case (.editing(var draft), .updateLocalizationCode(let locale)):
            draft.localizationCode = locale
            internalState = .editing(draft)
        case (.editing(var draft), .updatePoll(let poll)):
            draft.poll = poll
            internalState = .editing(draft)
        case (.editing(var draft), .updateVisibility(let newVisibility)):
            draft.visibility = newVisibility
            internalState = .editing(draft)
        case (.editing(var draft), .updateContentWarning(let sensitive, message: let disclaimer)):
            draft.containsSensitiveInformation = sensitive
            draft.sensitiveDisclaimer = disclaimer
            internalState = .editing(draft)
        case (.editing, .publish):
            internalState = await publishDraft()
        case (_, .reset):
            internalState = .initial
        default:
            internalState = .errored(.unsupportedEventDispatch)
        }
    }
}
