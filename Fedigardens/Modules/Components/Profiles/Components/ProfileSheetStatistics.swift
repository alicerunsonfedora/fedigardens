//
//  ProfileSheetStatistics.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/28/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import SwiftUI

struct ProfileSheetStatistics: View {
    var profile: Account
    var body: some View {
        HStack {
            ProfileSheetStatisticCellView(
                key: "profile.followers",
                value: "\(profile.followersCount)",
                systemName: "person.2.fill"
            )
            ProfileSheetStatisticCellView(
                key: "profile.following",
                value: "\(profile.followingCount)",
                systemName: "person.3.fill"
            )
            ProfileSheetStatisticCellView(
                key: "profile.statusescount",
                value: "\(profile.statusesCount)",
                systemName: "square.and.pencil"
            )
        }
    }
}
