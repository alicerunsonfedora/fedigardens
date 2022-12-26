//
//  LayoutStateRepresentable.swift
//  Gardens
//
//  Created by Marquis Kurt on 12/2/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

/// A protocol used on views to determine that their state can change.
protocol LayoutStateRepresentable {
    /// The current state of the view.
    var state: LayoutState { get set }
}

/// An enumeration representing the various states for a view to undergo.
enum LayoutState: Hashable {
    /// The view has been initialized, but no data has been loaded yet.
    case initial

    /// The view is currently fetching data.
    case loading

    /// The view has loaded data and is ready to render it.
    case loaded

    /// The view encountered an error when trying to load the data.
    case errored(message: String)
}
