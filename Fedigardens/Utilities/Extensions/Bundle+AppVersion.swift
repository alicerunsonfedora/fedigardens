//
//  Bundle+AppVersion.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 7/3/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

extension Bundle {
    /// Returns the version and build number of the app in the format "Version (Build)".
    /// - Note: If `CFBundleShortVersionString` and/or `CFBundloeVersion` are not found, their values will be replaced
    ///     with `0`.
    func getAppVersion() -> String {
        guard let info = infoDictionary else {
            return "0 (0.0)"
        }
        let appVersion = info["CFBundleShortVersionString"] as? String ?? "0.0"
        let appBuild = info["CFBundleVersion"] as? String ?? "0"
        return "\(appVersion) (\(appBuild))"
    }
}
