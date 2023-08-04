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

public actor ComposerFlow {
    private struct SettingConstants {
        @GardenSetting(key: .enforceCharacterLimit)
        static var enforcesCharacterLimit = true
    }
    public enum State: Equatable, Hashable {
        case initial
        case editing(ComposerDraft)
        case published(Status)
        case errored(ComposerFlowError)
    }

    public enum Event {
        case startDraft(ComposerDraft)
        case updateContent(String)
        case updatePoll(ComposerDraftPoll?)
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

    func publishDraft() async -> State {
        guard case .editing(let composerDraft) = internalState else {
            return .errored(.noDraftSupplied)
        }
        if SettingConstants.enforcesCharacterLimit, composerDraft.count > characterLimit {
            return .errored(.exceedsCharacterLimit)
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
            return .errored(.mastodonError(fetchError))
        }
    }
}

extension ComposerFlow: StatefulFlowProviding {
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
