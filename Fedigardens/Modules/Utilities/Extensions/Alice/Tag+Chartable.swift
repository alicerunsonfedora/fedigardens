//
//  Tag+Chartable.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/28/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import UIKit

extension History {
    func date() -> Date {
        let timeInterval = TimeInterval(self.day) ?? 0
        return Date(timeIntervalSince1970: timeInterval)
    }

    func numberOfUses() -> Int {
        return Int(uses) ?? 0
    }

    func numberOfAccounts() -> Int {
        return Int(accounts) ?? 0
    }
}
