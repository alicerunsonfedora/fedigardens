//
//  ProfileSheetViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/14/23.
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

class ProfileSheetViewModel: ObservableObject {
    @Published var profile: Account?
    @Published var statuses = [Status]()
    @Published var layoutState = LayoutState.initial

    func fetchStatuses() async {
        guard let profile else { return }
        DispatchQueue.main.async {
            self.layoutState = .loading
        }
        let response: Alice.Response<[Status]> = await Alice.shared.request(.get, for: .accountStatuses(id: profile.id))
        switch response {
        case .success(let statuses):
            DispatchQueue.main.async {
                self.statuses = statuses
                self.layoutState = .loaded
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.layoutState = .errored(message: error.localizedDescription)
            }
            print("Fetch error: \(error.localizedDescription)")
        }
    }
}
