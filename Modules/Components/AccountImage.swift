//
//  AccountAuthorImage.swift
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

import Chica
import SwiftUI

struct AccountImage: View {
    enum ProfileImageSize: CGFloat {
        case small = 20
        case medium = 32
        case large = 48
        case xlarge = 64
    }

    var author: Account

    init(author: Account) {
        self.author = author
    }

    fileprivate init(author: Account, profileImageSize: ProfileImageSize) {
        self.author = author
        self.profileImageSize = profileImageSize
    }

    fileprivate var profileImageSize: ProfileImageSize = .small

    var body: some View {
        AsyncImage(url: .init(string: author.avatarStatic)) { image in
            image
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
        } placeholder: {
            Image(systemName: "person.circle")
                .imageScale(.large)
        }
        .frame(width: profileImageSize.rawValue, height: profileImageSize.rawValue)
    }
}

extension AccountImage {
    func profileSize(_ size: ProfileImageSize) -> AccountImage {
        AccountImage(author: author, profileImageSize: size)
    }
}
