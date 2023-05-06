//
//  RecursiveNavigationView.swift
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
import SwiftUI

enum RecursiveNavigationLevel {
    case parent
    case child
}

struct RecursiveNavigationStack<T: Hashable, NavigationContent: View, NavDestination: View>: View {
    typealias Destination = (T) -> NavDestination
    typealias Level = RecursiveNavigationLevel

    var level: Level
    var content: () -> NavigationContent

    init(level: Level, content: @escaping () -> NavigationContent) {
        self.level = level
        self.content = content
    }

    fileprivate init(
        level: Level,
        content: @escaping () -> NavigationContent,
        destinationTypes: [HashableType<T>: Destination]
    ) {
        self.level = level
        self.content = content
        self.destinationTypes = destinationTypes
    }

    fileprivate var destinationTypes: [HashableType<T>: Destination] = [:]

    var body: some View {
        Group {
            switch level {
            case .parent:
                NavigationStack {
                    content()
                        .modifier(RecursiveNavigationDestinationModifier(navigationDestinations: destinationTypes))
                }
            case .child:
                content()
            }
        }
    }
}

extension RecursiveNavigationStack {
    func recursiveDestination(of _: T.Type, destination: @escaping (T) -> NavDestination) -> Self {
        var copiedDestinations = destinationTypes
        copiedDestinations[T.self] = destination
        return RecursiveNavigationStack(level: level, content: content, destinationTypes: copiedDestinations)
    }
}

private struct RecursiveNavigationDestinationModifier<T: Hashable, Destination: View>: ViewModifier {
    typealias NavigationDestinationLookup = [HashableType<T>: (T) -> Destination]
    let navigationDestinations: NavigationDestinationLookup
    func body(content: Content) -> some View {
        var updatedDestinations = navigationDestinations
        let nextDestination: NavigationDestinationLookup.Element?
        if !updatedDestinations.isEmpty {
            nextDestination = updatedDestinations.popFirst()
        } else {
            nextDestination = nil
        }

        // calling the builder
        return buildView(content: content, nextDestination: nextDestination, destinations: updatedDestinations)
    }

    // Using @ViewBuilder to accept different results type
    @ViewBuilder private func buildView(
        content: Content,
        nextDestination: NavigationDestinationLookup.Element?,
        destinations: NavigationDestinationLookup
    ) -> some View {
        if let destination = nextDestination {
            content
                .navigationDestination(for: destination.key.base.self, destination: destination.value)
                .modifier(RecursiveNavigationDestinationModifier(navigationDestinations: destinations))
        } else {
            content
        }
    }
}
