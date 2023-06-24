@testable import Alice
import AliceMockingbird
import SwiftUI
import XCTest

final class AliceNetworkTests: XCTestCase {
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

    var networkProvider: Alice?
    var keychain: AliceMockKeychain?

    override func setUp() async throws {
        let mockKeychain = AliceMockKeychain()
        keychain = AliceMockKeychain()
        Alice.instanceDomain = "hyrma.example"
        networkProvider = Alice(using: AliceMockSession.self, with: .init(using: mockKeychain))
    }

    override func tearDown() async throws {
        networkProvider = nil
        keychain?.flush()
        keychain = nil
    }

    func testFetchAuthenticatedAccount() async throws {
        await callNetworkProvider(auth: true) { network, _ in
            let accountResponse: Alice.Response<Account> = await network.get(.account(id: "1"))
            switch accountResponse {
            case .success(let account):
                XCTAssertEqual(account.id, "1")
                XCTAssertEqual(account.acct, "admin")
            case .failure(let error):
                XCTFail("Received error: \(error.localizedDescription)")
            }
        }
    }

    func testFetchFailureOnAuthentication() async throws {
        await callNetworkProvider(auth: false) { network, _ in
            let response: Alice.Response<Account> = await network.get(.account(id: "1"))
            switch response {
            case .success(let result):
                XCTFail("Fetched account: \(result.acct)")
            case .failure(let error):
                switch error {
                case .mastodonAPIError(let error, _):
                    XCTAssertEqual(error.error, "The access token is invalid")
                default:
                    XCTFail("Failed for some other reason: \(error.localizedDescription)")
                }
            }
        }
    }

    func callNetworkProvider(
        auth: Bool = true,
        _ operation: (Alice, AliceMockKeychain) async throws -> Void
    ) async rethrows {
        guard let network = networkProvider, let keychain else {
            return XCTFail("Network provider or keychain doesn't exist.")
        }
        if auth {
            await network.authenticator.startOauthFlow(for: "hyrma.example", using: network, store: keychain)
            await network.authenticator.continueOauthFlow("auth", using: network, store: keychain)
        }
        try await operation(network, keychain)
    }
}
