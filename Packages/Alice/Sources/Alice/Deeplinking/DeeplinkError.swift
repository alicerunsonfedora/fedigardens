/*
*   THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THIS
*   NON-VIOLENT PUBLIC LICENSE v4 ("LICENSE"). THE WORK IS PROTECTED BY
*   COPYRIGHT AND ALL OTHER APPLICABLE LAWS. ANY USE OF THE WORK OTHER THAN
*   AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS PROHIBITED. BY
*   EXERCISING ANY RIGHTS TO THE WORK PROVIDED IN THIS LICENSE, YOU AGREE
*   TO BE BOUND BY THE TERMS OF THIS LICENSE. TO THE EXTENT THIS LICENSE
*   MAY BE CONSIDERED TO BE A CONTRACT, THE LICENSOR GRANTS YOU THE RIGHTS
*   CONTAINED HERE IN AS CONSIDERATION FOR ACCEPTING THE TERMS AND
*   CONDITIONS OF THIS LICENSE AND FOR AGREEING TO BE BOUND BY THE TERMS
*   AND CONDITIONS OF THIS LICENSE.
*
*   This source file is part of the Codename Starlight open source project
*   This file was created by Alejandro Modroño Vara on 30/10/21.
*
*   See `LICENSE.txt` for license information
*   See `CONTRIBUTORS.txt` for project authors
*
*/
import Foundation

public enum DeeplinkError: Error {

    // Thrown when the received scheme does not match with the specified scheme.
    case unknownScheme(received: String?)

    // Thrown when the received link is not defined in the Deeplink enum.
    case unknownDeeplink(received: String?)

    // Thrown when the received link should have query parameters but none, or not enough
    // were passed.
    case expectedQueryParameters(expecting: Int, received: Int)

    // Thrown when an unknown query parameter is passed.
    case unknownQueryParameter(expecting: String)

    // Throw when an expected resource is not found
    case notFound

    // Throw in all other cases
    case unexpected(code: Int)
}

extension DeeplinkError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknownScheme(let received):
            return "The received scheme (\"\(received)\") does not match with the one specified."
        case .unknownDeeplink(let received):
            return "The received link \(received != nil ? "(\"\(received)\")" : "") does not match with any of the ones defined in the Deeplink enum."
        case .expectedQueryParameters(let count, let received):
            return "The received link should have \(count) query parameters, but \(count > received ? "only" : "") \(received) \(received == 1 ? "was" : "were") received."
        case .unknownQueryParameter(let expecting):
            return "The deeplink expects at least a query parameter named \"\(expecting)\"."
        case .notFound:
            return "The specified item could not be found."
        case .unexpected(let code):
            return "An unexpected error occurred. Code: \(code)."
        }
    }
}

