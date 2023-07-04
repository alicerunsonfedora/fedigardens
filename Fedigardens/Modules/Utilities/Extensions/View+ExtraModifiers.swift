//
//  View+ExtraModifiers.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 5/4/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

extension View {
    func onReceive(of name: Notification.Name,
                   from center: NotificationCenter = .default,
                   in object: AnyObject? = nil,
                   perform action: @escaping (Notification) -> Void) -> some View {
        onReceive(center.publisher(for: name, object: object), perform: action)
    }

    func onOpenURL(perform task: @escaping (URL) async -> Void) -> some View {
        self.onOpenURL(perform: { url in
            Task {
                await task(url)
            }
        })
    }
}
