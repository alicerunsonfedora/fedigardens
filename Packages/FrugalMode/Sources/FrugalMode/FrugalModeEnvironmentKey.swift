//
//  FrugalModeEnvironmentKey.swift
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

private struct FrugalModeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    /// Whether frugal mode should be enforced all the time, rather than per user defaults.
    ///
    /// Typically, this environment variable can be used to suspend expensive tasks or selectively display contents that aren't
    /// computationally intensive with respect to time and/or resources.
    ///
    /// Use this alongside ``FrugalModeFlow`` to automatically override frugal mode settings based on Low Power Mode:
    /// ```swift
    /// import FrugalMode
    /// import SwiftUI
    ///
    /// @main
    /// struct MainApp: App {
    ///     private var frugalFlow = FrugalFlow()
    ///
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .environment(\.frugalMode,
    ///                             (frugalFlow.state == .overridden))
    ///                 .onAppear {
    ///                   Task { await frugalFlow.emit(.checkOverrides) }
    ///                 }
    ///          }
    ///      }
    /// }
    /// ```
    var enforcedFrugalMode: Bool {
        get { return self[FrugalModeEnvironmentKey.self] }
        set { self[FrugalModeEnvironmentKey.self] = newValue }
    }
}
