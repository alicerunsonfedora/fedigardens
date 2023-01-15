//
//  Emojis.swift
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

import SwiftUI
import EmojiText
import Alice

extension Emoji {
    func remote() -> RemoteEmoji {
        return RemoteEmoji(shortcode: self.shortcode, url: self.url)
    }
}

private struct CustomEmojisEnvironmentKey: EnvironmentKey {
    static let defaultValue: [RemoteEmoji] = []
}

extension EnvironmentValues {
    var customEmojis: [RemoteEmoji] {
        get { self[CustomEmojisEnvironmentKey.self] }
        set { self[CustomEmojisEnvironmentKey.self] = newValue }
    }
}
