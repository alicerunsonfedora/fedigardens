import XCTest
@testable import Alice
import SwiftUI

final class chicaTests: XCTestCase {

    /// An EnvironmentValue that allows us to open a URL using the appropriate system service.
    ///
    /// Can be used as follows:
    /// ```
    /// openURL(URL(string: "url")!)
    /// ```
    /// or
    ///```
    /// openURL(url) // Where URL.type == URL
    /// ```
    @Environment(\.openURL) private var openURL

    func testOauth() async throws {

        await Chica.OAuth.shared.startOauthFlow(for: "mastodon.online")

    }

    func doWhatever(_ parameters: [String : String]?) {
        print("RECEIVED DEEP LINK...")
        if let parameters = parameters {
            for parameter in parameters {
                print("\(parameter.key) : \(parameter.value)")
            }
        }
    }

    func testBasicRequests() async throws {

        let account = try! await getAccount(id: "1")

        if Chica.INSTANCE_DOMAIN == "mastodon.social" {
            XCTAssertEqual(account!.username, "Gargron")
        } else if Chica.INSTANCE_DOMAIN == "mastodon.technology" {
            XCTAssertEqual(account!.username, "ashfurrow")
        }
        
        XCTAssertEqual(account!.id, "1")

//        XCTAssertThrowsError(async { try await getAccount(id: "0932840923890482309409238409380948") })

    }
}

func getAccount(id: String) async throws -> Account? {
    return try await Chica().request(.get, for: .account(id: id))
}

