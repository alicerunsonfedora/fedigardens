//
//  RecursiveNavigationView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 8/7/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

/// An enumeration that represents the different level definitions for a recursive navigation stack.
public enum RecursiveNavigationStackLevel {
    /// The root or parent level.
    case parent

    /// A child level.
    case child
}

/// A navigation stack type that allows recursive definitions.
///
/// Similarly to a navigation stack, this is used to create a navigation stack that pushes a detail view based on its
/// type:
/// ```swift
/// struct Employee: Identifiable, Hashable {
///     var id = UUID()
///     var name: String
///     var department: String
/// }
///
/// RecursiveNavigationStack(level: .parent) {
///     ...
/// }
/// .recursiveDestination(of: Employee.self) { employee in
///     EmployeeDetailView(employee, recursiveLevel: .child)
/// }
/// ```
public struct RecursiveNavigationStack<T: Hashable, NavigationContent: View, NavDestination: View>: View {
    public typealias Destination = (T) -> NavDestination
    public typealias Level = RecursiveNavigationStackLevel

    var level: Level
    var content: () -> NavigationContent

    /// Creates a recursive navigation stack.
    /// - parameter level: The level the stack sits in. Defaults to the parent level.
    /// - Parameter content: The content that will define this stack.
    public init(level: Level = .parent, content: @escaping () -> NavigationContent) {
        self.level = level
        self.content = content
    }

    init(level: Level,
         content: @escaping () -> NavigationContent,
         destinationTypes: [HashableType<T>: Destination]) {
        self.level = level
        self.content = content
        self.destinationTypes = destinationTypes
    }

    var destinationTypes: [HashableType<T>: Destination] = [:]

    public var body: some View {
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

public extension RecursiveNavigationStack {
    /// Defines a nagivation destination in a recursive nagivation stack.
    /// - Parameter of: The hashable type that this destination originates from. Typically, this is the type of value
    ///   passed in a navigation link.
    /// - Parameter destination: The destination content that is pushed on the navigation stack when a value of the
    ///   specified type is registered.
    func recursiveDestination(of _: T.Type, destination: @escaping (T) -> NavDestination) -> Self {
        var copiedDestinations = destinationTypes
        copiedDestinations[T.self] = destination
        return RecursiveNavigationStack(level: level, content: content, destinationTypes: copiedDestinations)
    }
}

struct RecursiveNavigationDestinationModifier<T: Hashable, Destination: View>: ViewModifier {
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
    @ViewBuilder private func buildView(content: Content,
                                        nextDestination: NavigationDestinationLookup.Element?,
                                        destinations: NavigationDestinationLookup) -> some View {
        if let destination = nextDestination {
            content
                .navigationDestination(for: destination.key.base.self, destination: destination.value)
                .modifier(RecursiveNavigationDestinationModifier(navigationDestinations: destinations))
        } else {
            content
        }
    }
}
