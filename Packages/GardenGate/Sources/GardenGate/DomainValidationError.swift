//
//  DomainValidationError.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 24/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

public enum DomainValidationError: Error {
    case invalid(domain: String)
    case rejected(domain: String)

    public var message: String {
        switch self {
        case .invalid(let domain):
            String(format: NSLocalizedString("auth.badurl.message", bundle: .module, comment: "Invalid URL (FGD-22)"),
                   domain)
        case.rejected(let domain):
            String(format: NSLocalizedString("auth.disallowed.message", bundle: .module, comment: "In disallow list"),
                   domain)
        }
    }
}

extension DomainValidationError: LocalizedError {
    public var localizedDescription: String {
        message
    }
}
