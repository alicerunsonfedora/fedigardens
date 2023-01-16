//
//  StatusDetailViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/24/22.
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
import Drops
import UIKit

class StatusDetailViewModel: ObservableObject {
    struct ContextCaller: Hashable {
        var id: String
        var status: Status
    }

    @Published var status: Status?
    @Published var quote: Status?
    @Published var quoteSource: Status.QuoteSource?
    @Published var context: Context?
    @Published var shouldOpenCompositionTool: AuthoringContext?
    @Published var expandAncestors = false
    @Published var state = LayoutState.initial
    @Published var displayedProfile: Account?

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
            self.state = .loading
            self.clear()
            self.status = status
        }
        await getContext(for: status)
        await getQuote(for: status)
    }

    func getContext(for status: Status? = nil) async {
        let realStatus = status ?? self.status
        guard let realStatus else { return }

        DispatchQueue.main.async { self.state = .loading }
        let response: Alice.Response<Context> = await Alice.shared.request(.get, for: .context(id: realStatus.id))
        switch response {
        case .success(let arrivingContext):
            DispatchQueue.main.async {
                self.context = arrivingContext
                self.state = .loaded
            }
        case .failure(let error):
            print("Couldn't fetch context: \(error.localizedDescription)")
            DispatchQueue.main.async { self.state = .errored(message: error.localizedDescription) }
        }
    }

    func getQuote(for status: Status? = nil) async {
        let realStatus = status ?? self.status
        guard let realStatus, realStatus.quotedReply() != nil else { return }
        DispatchQueue.main.async { self.state = .loading }
        let response: Pip.Response<Status> = await Pip.shared.requestQuote(of: realStatus)
        switch response {
        case .success(let quotedReply):
            DispatchQueue.main.async {
                self.quote = quotedReply
                self.quoteSource = status?.quotedReply()?.0
                self.state = .loaded
            }
        case .failure(let error):
            print("Couldn't fetch quoted reply: \(error)")
            DispatchQueue.main.async { self.state = .errored(message: error.localizedDescription) }
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
        await updateStatus(
            drop: .init(
                title: NSLocalizedString(
                    status?.favourited == true ? "drop.unfavorite" : "drop.favorite",
                    comment: "Favorite drop"
                ),
                icon: UIImage(systemName: "star.fill")
            )
        ) { state in
            await Alice.shared.request(
                .post, for: state.favourited == true ? .unfavorite(id: state.id) : .favourite(id: state.id)
            )
        }
    }

    // Toggles whether the user boosts the status.
    func toggleReblogStatus() async {
        await updateStatus(
            drop: .init(
                title: NSLocalizedString(
                    status?.reblogged == true ? "drop.unreblog" : "drop.reblog",
                    comment: "Reblog drop"
                ),
                icon: UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")
            )
        ) { state in
            await Alice.shared.request(
                .post, for: state.reblogged == true ? .unreblog(id: state.id) : .reblog(id: state.id)
            )
        }
    }

    // Toggles whether the user has saved the status.
    func toggleBookmarkedStatus() async {
        await updateStatus(
            drop: .init(
                title: NSLocalizedString(
                    status?.bookmarked == true ? "drop.unsave" : "drop.save",
                    comment: "Save drop"
                ),
                icon: UIImage(systemName: "bookmark.fill")
            )
        ) { state in
            await Alice.shared.request(
                .post, for: state.bookmarked == true ? .undoSave(id: state.id) : .save(id: state.id)
            )
        }
    }

    private func clear() {
        self.status = nil
        self.context = nil
        self.quote = nil
    }

    /// Make a request to update the current status.
    /// - Parameter means: A closure that will be performed to update the status. Should return an optional
    /// status which represents the newly modified status.
    private func updateStatus(drop: Drop? = nil, by means: (Status) async -> Alice.Response<Status>) async {
        guard let status else { return }
        let response = await means(status)
        switch response {
        case .success(let updated):
            DispatchQueue.main.async {
                self.status = updated
                if let drop {
                    Drops.show(drop)
                }
            }
        case .failure(let error):
            print("Error occured when updating status: \(error.localizedDescription)")
        }
    }
}
