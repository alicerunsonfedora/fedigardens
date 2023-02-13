//
//  SettingsBlocklistViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/22/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import Alice
import Combine

class SettingsBlocklistViewModel: ObservableObject {
    @Published var blockedServers = [String]()
    @Published var instanceBlocks = [DomainBlock]()
    @Published var shouldDisplayInsertionRequest = false
    @Published var requestedDomainInsertionText = ""
    @Published var layoutState = LayoutState.initial

    init() {}

    func getBlockedServers() async {
        DispatchQueue.main.async { self.layoutState = .loading }
        let response: Alice.Response<[String]> = await Alice.shared.get(.blockedServers)
        switch response {
        case .success(let blocked):
            DispatchQueue.main.async {
                self.blockedServers = blocked
                self.layoutState = .loaded
            }
        case .failure(let error):
            print("Fetch blocked error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.layoutState = .errored(message: error.localizedDescription)
            }
        }
    }

    func getInstanceWideBlocks() async {
        DispatchQueue.main.async { self.layoutState = .loading }
        let response: Alice.Response<[DomainBlock]> = await Alice.shared.get(.instanceBlocks)
        switch response {
        case .success(let instanceBlocks):
            DispatchQueue.main.async {
                self.instanceBlocks = instanceBlocks
                self.layoutState = .loaded
            }
        case .failure(let error):
            print("Fetch instance block error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.layoutState = .errored(message: error.localizedDescription)
            }
        }
    }

    func deleteBlockedServers(at offsets: IndexSet) {
        offsets.forEach { offset in
            let domain = blockedServers.remove(at: offset)
            Task { await self.deleteBlockedServer(with: domain) }
        }
    }

    func insertBlockedServer() async {
        let response: Alice.Response<EmptyNode> = await Alice.shared.post(
            .blockedServers,
            params: ["domain": requestedDomainInsertionText]
        )
        switch response {
        case .success:
            DispatchQueue.main.async {
                self.blockedServers.append(self.requestedDomainInsertionText)
                self.requestedDomainInsertionText = ""
            }
        case .failure(let error):
            print("Block domain error: \(error.localizedDescription)")
        }
    }

    private func deleteBlockedServer(with domain: String) async {
        let response: Alice.Response<EmptyNode> = await Alice.shared.delete(
            .blockedServers,
            params: ["domain": domain]
        )

        switch response {
        case .success:
            print("Domain \(domain) deleted from blocklists.")
        case .failure(let error):
            print("Unblock domain error: \(error.localizedDescription)")
        }
    }
}
