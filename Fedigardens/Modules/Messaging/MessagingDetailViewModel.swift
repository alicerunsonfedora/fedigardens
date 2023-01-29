//
//  MessagingDetailViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/27/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import Combine
import Alice

class MessagingDetailViewModel: ObservableObject {
    @Published var conversation: Conversation?
    @Published var context: Context?

    init() {
        self.conversation = nil
        self.context = nil
    }

    init(conversation: Conversation) {
        self.conversation = conversation
    }

    func replaceConversation(with newConversation: Conversation) async -> LayoutState {
        DispatchQueue.main.async {
            self.context = nil
            self.conversation = newConversation
        }
        return await fetchContext(of: newConversation)
    }

    func fetchContext(of newConversation: Conversation?) async -> LayoutState {
        let fetchContextRequest = newConversation ?? conversation
        guard let request = fetchContextRequest?.lastStatus?.id else { return .loaded }
        let response: Alice.Response<Context> = await Alice.shared.get(.context(id: request))
        switch response {
        case .success(let context):
            DispatchQueue.main.async {
                self.context = context
            }
            return .loaded
        case .failure(let error):
            print("Couldn't fetch context: \(error)")
            return .errored(message: error.localizedDescription)
        }
    }
}
