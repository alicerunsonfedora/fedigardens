import XCTest
@testable import Alice
import SwiftUI

final class AliceTests: XCTestCase {

    /// An EnvironmentValue that allows us to open a URL using the appropriate system service.
    ///
    /// Can be used as follows:
    /// ```
    /// openURL(URL(string: "url")!)
    /// ```
    /// or
    /// ```
    /// openURL(url) // Where URL.type == URL
    /// ```
    @Environment(\.openURL) private var openURL

    func testOauth() async throws {
        await Alice.OAuth.shared.startOauthFlow(for: "mastodon.online")
    }

    func doWhatever(_ parameters: [String: String]?) {
        print("RECEIVED DEEP LINK...")
        if let parameters = parameters {
            for parameter in parameters {
                print("\(parameter.key) : \(parameter.value)")
            }
        }
    }

    func testBasicRequests() async throws {

        let account = try! await getAccount(id: "1")

        if Alice.instanceDomain == "mastodon.social" {
            XCTAssertEqual(account!.username, "Gargron")
        } else if Alice.instanceDomain == "mastodon.technology" {
            XCTAssertEqual(account!.username, "ashfurrow")
        }

        XCTAssertEqual(account!.id, "1")

//        XCTAssertThrowsError(async { try await getAccount(id: "0932840923890482309409238409380948") })

    }
}

func getAccount(id: String) async throws -> Account? {
    let response: Alice.Response<Account> = await Alice().request(.get, for: .account(id: id))
    switch response {
    case .success(let account):
        return account
    case .failure:
        return nil
    }
}
