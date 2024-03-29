//
//  ProfileImage.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 5/8/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import FrugalMode
import GardenSettings
import SwiftUI

public struct ProfileImage: View {
    @AppStorage(.frugalMode) var frugalMode: Bool = false
    @Environment(\.enforcedFrugalMode) var enforcedFrugalMode

    public enum ProfileImageSize: CGFloat {
        case small = 20
        case medium = 32
        case large = 48
        case xlarge = 64
        case xxlarge = 84
    }

    var author: Account

    public init(author: Account) {
        self.author = author
    }

    fileprivate init(author: Account, profileImageSize: ProfileImageSize) {
        self.author = author
        self.profileImageSize = profileImageSize
    }

    fileprivate var profileImageSize: ProfileImageSize = .small

    public var body: some View {
        Group {
            if enforcedFrugalMode || frugalMode {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
            } else {
                AsyncImage(url: .init(string: author.avatarStatic)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            }
        }
        .frame(width: profileImageSize.rawValue, height: profileImageSize.rawValue)
    }
}

public extension ProfileImage {
    func profileSize(_ size: ProfileImageSize) -> ProfileImage {
        ProfileImage(author: author, profileImageSize: size)
    }
}
