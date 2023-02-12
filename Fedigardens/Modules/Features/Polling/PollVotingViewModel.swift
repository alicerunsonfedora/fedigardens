//
//  PollVotingViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/11/23.
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

class PollVotingViewModel: ObservableObject {
    @Published var poll: Poll?
    @Published var currentVote: Int = -1

    func expirationIsNear(difference: TimeInterval) -> Bool {
        guard let expiry = poll?.expiresAt, let date = DateFormatter.mastodon.date(from: expiry) else { return false }
        return abs(date.distance(to: .now)) <= difference
    }

    func pollExpirationDate() -> String? {
        guard let expiration = poll?.expiresAt, let date = DateFormatter.mastodon.date(from: expiration) else {
            return nil
        }

        let relativeFormatter = RelativeDateTimeFormatter()
        return relativeFormatter.localizedString(for: date, relativeTo: .now)
    }

    func submit(completion: @escaping (Poll) -> Void) async {
        guard let poll, (0..<poll.options.count).contains(currentVote) else { return }
        let response: Alice.Response<Poll> = await Alice.shared.post(
            .votePoll(id: poll.id),
            params: ["choices[]": String(currentVote)]
        )
        switch response {
        case .success(let result):
            DispatchQueue.main.async {
                self.poll = result
                completion(result)
            }
        case .failure(let error):
            print("Vote error: \(error.localizedDescription)")
        }
    }
}
