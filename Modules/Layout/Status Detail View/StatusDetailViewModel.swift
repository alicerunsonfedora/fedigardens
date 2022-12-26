//
//  StatusDetailViewModel.swift
//  Gardens
//
//  Created by Marquis Kurt on 12/24/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import Combine
import Chica

class StatusDetailViewModel: ObservableObject {
    struct ContextCaller: Hashable {
        var id: String
        var status: Status
    }

    @Published var status: Status?
    @Published var quote: Status?
    @Published var context: Context?

    var containsUndisclosedContent: Bool {
        guard let status else { return false }
        return !status.spoilerText.isEmpty
    }

    init() {}

    init(status: Status) {
        self.status = status
    }

    func replace(status: Status) async {
        DispatchQueue.main.async {
            self.clear()
            self.status = status
        }
        await getContext(for: status)
        await getQuote(for: status)
    }

    func getContext(for status: Status? = nil) async {
        let realStatus = status ?? self.status
        guard let realStatus else { return }
        do {
            let newContext: Context? = try await Chica.shared.request(.get, for: .context(id: realStatus.id))
            DispatchQueue.main.async { self.context = newContext }
        } catch {
            print("Couldn't fetch context: \(error)")
        }
    }

    func getQuote(for status: Status? = nil) async {
        let realStatus = status ?? self.status
        guard let realStatus, realStatus.quotedReply() != nil else { return }
        do {
            let quotedReply: Status? = try await Chica.shared.requestQuote(of: realStatus)
            DispatchQueue.main.async { self.quote = quotedReply }
        } catch {
            print("Couldn't fetch quoted reply: \(error)")
        }
    }

    func contextCaller(for reply: Status) -> ContextCaller {
        return ContextCaller(id: reply.id, status: reply)
    }

    func navigationTitle(with level: RecursiveNavigationLevel) -> String {
        if let status {
            return "\(level == .parent ? "Status" : "Reply") - \(status.account.getAccountName())"
        }
        return "\(level == .parent ? "Status" : "Reply")"
    }

    // Toggles whether the user likes the status.
    func toggleFavoriteStatus() async {
        await updateStatus { state in
            try await Chica.shared.request(
                .post, for: state.favourited == true ? .unfavorite(id: state.id) : .favourite(id: state.id)
            )
        }
    }

    // Toggles whether the user boosts the status.
    func toggleReblogStatus() async {
        await updateStatus { state in
            try await Chica.shared.request(
                .post, for: state.reblogged == true ? .unreblog(id: state.id) : .reblog(id: state.id)
            )
        }
    }

    private func clear() {
        self.status = nil
        self.context = nil
        self.quote = nil
    }

    /// Make a request to update the current status.
    /// - Parameter means: A closure that will be performed to update the status. Should return an optional status,
    ///     which represents the newly modified status.
    private func updateStatus(by means: (Status) async throws -> Status?) async {
        guard let status else { return }
        var updated: Status?
        do {
            updated = try await means(status)
        } catch {
            print("Error occured when updating status: \(error.localizedDescription)")
            return
        }

        if let new = updated {
            DispatchQueue.main.async { [self] in
                self.status = new
            }
        }
    }
}
