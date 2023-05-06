//
//  Acknowledgement+License.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/31/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import AckGen
import Foundation

extension Acknowledgement {
    static func license(named name: String, ofType type: String = "txt") -> String {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else { return "" }
        do {
            return try String(contentsOfFile: path)
        } catch {
            return ""
        }
    }
}
