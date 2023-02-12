//
//  UIDevice+Model.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import UIKit
import SwiftUI

extension UIDevice {
    typealias ModelName = String
    /// Returns the device model identifier.
    /// Pulled from https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model.
    static let model: ModelName = {
        #if targetEnvironment(simulator)
        return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "arm64"
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
        #endif
    }()
}

private struct DeviceModelEnvironmentKey: EnvironmentKey {
    static let defaultValue: UIDevice.ModelName = UIDevice.model
}

extension EnvironmentValues {
    var deviceModel: UIDevice.ModelName {
        get { self[DeviceModelEnvironmentKey.self] }
        set { self[DeviceModelEnvironmentKey.self] = newValue }
    }
}
