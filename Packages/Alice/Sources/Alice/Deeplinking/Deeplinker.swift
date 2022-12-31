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
import SwiftUI

//  Deep linking with chica works in two parts:
//
//
//  1. First, the app's URL-scheme is called, followed by a specific set
//     of query items. These query items are sent to `Chica.manage()`, which
//     will then divide the url into tokens.
//
//  2. Secondly, chica will return a `Chica.Deeplinker.Deeplink` according to
//     the type of url received and its associated values.
//

/// The class in charge of all the Deep-linking process.
/// For a detailed explanation of how this works, go to `Deeplinker.swift`
public class Deeplinker {

    /// The types of deeplinks that the application expects.
    public enum Deeplink: Equatable, CaseIterable {

        public static var allCases: [Deeplinker.Deeplink] {
            return [.home, .oauth(code: ""), .profile(id: "")]
        }

        case home
        case oauth(code: String)
        case profile(id: String)

        /// The keyword of the deeplink.
        public var description: String {
            switch self {
            case .home:
                return "home"
            case .oauth:
                return "oauth"
            case .profile:
                return "profile"
            }
        }

        var expectsAssociatedValues: Int? {
            switch self {
            case .home:
                return nil
            case .oauth:
                return 1
            case .profile:
                return 1
            }
        }
        
    }

    /// A singleton everybody can access to.
    static public let shared = Deeplinker()

    public func manage(url: URL) throws -> Deeplink {

        guard url.scheme == Alice.shared.urlPrefix else {
            throw DeeplinkError.unknownScheme(received: url.scheme)
        }

        for deeplink in Deeplink.allCases {
            if deeplink.description == url.host {

                //  We check that there are no other query parameters
                guard let queryItems = url.queryParameters else {

                    //  We make sure that the deeplink was not expecting any
                    //  parameter, and if so, we return the deeplink.
                    //
                    //  If the deeplink was actually expecting them, we return
                    //  error.
                    guard let values = deeplink.expectsAssociatedValues else {
                        return deeplink
                    }

                    throw DeeplinkError.expectedQueryParameters(expecting: values, received: 0)
                }

                //  Now, we make sure that the deeplink was actually expecting
                //  parameters, or else we return an error.
                guard deeplink.expectsAssociatedValues != nil else {
                    throw DeeplinkError.expectedQueryParameters(expecting: 0, received: queryItems.count)
                }

                switch url.host {
                case "oauth":
                    guard let code = queryItems.first(where: { $0.key == "code" })?.value else {
                        throw DeeplinkError.unknownQueryParameter(expecting: "code")
                    }
                    return .oauth(code: code)
                case "profile":
                    guard let id = queryItems.first(where: { $0.key == "id" })?.value else {
                        throw DeeplinkError.unknownQueryParameter(expecting: "id")
                    }
                    return .profile(id: id)
                default:
                    throw DeeplinkError.unknownDeeplink(received: url.host)
                }
            }

        }

        throw DeeplinkError.unknownDeeplink(received: url.host)

    }

    /// Refreshes a deeplink
    public func refresh(_ deeplink: inout Deeplink?) {

        //  It is important to reset the deeplink or else if a user opens
        //  the same link twice, it won't work.

        deeplink = nil
    }

}
