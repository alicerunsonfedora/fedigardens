@testable import Alice
import SwiftUI
import XCTest

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

    func testOauth() async throws {
        await callNetworkProvider { network, keychain in
            await network.authenticator.startOauthFlow(for: "hyrma.example", using: network, store: keychain) { url in
                XCTAssertTrue(url.absoluteString.starts(with: "https://hyrma.example"))
            } onBadURL: { error in
                XCTFail("Failure: \(error)")
            }
        }
    }

    func testBasicRequests() async throws {
        await callNetworkProvider { network, keychain in
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

    func callNetworkProvider(_ operation: (Alice, AliceMockKeychain) async throws -> Void) async rethrows {
        guard let networkProvider, let keychain else { return XCTFail("Network provider or keychain doesn't exist.") }
        try await operation(networkProvider, keychain)
    }
}
