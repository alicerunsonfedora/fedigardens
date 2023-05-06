//
//  AliceAuthenticationTests.swift
//  
//
//  Created by Marquis Kurt on 5/6/23.
//

@testable import Alice
import SwiftUI
import XCTest

final class AliceAuthenticationTests: XCTestCase {
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
        networkProvider = Alice(using: AliceMockSession.self, with: .init(using: mockKeychain))
    }

    override func tearDown() async throws {
        networkProvider = nil
        keychain?.flush()
        keychain = nil
    }

    func testAuthenticationFlowStarts() async throws {
        await callNetworkProvider(auth: false) { network, keychain in
            await network.authenticator.startOauthFlow(for: "hyrma.example", using: network, store: keychain) { url in
                XCTAssertTrue(url.absoluteString.starts(with: "https://hyrma.example"))

                ["starlight_client_id", "starlight_client_secret", "starlight_instance_domain"].forEach { field in
                    XCTAssertNotNil(keychain.getSecureStore(field))
                }
            } onBadURL: { error in
                XCTFail("Failure: \(error)")
            }
        }
    }

    func testAuthenticationFlowFinishes() async throws {
        await callNetworkProvider(auth: false) { network, keychain in
            await network.authenticator.startOauthFlow(for: "hyrma.example", using: network, store: keychain) { url in
                XCTAssertTrue(url.absoluteString.starts(with: "https://hyrma.example"))
            } onBadURL: { error in
                XCTFail("Failure: \(error)")
            }
            await network.authenticator.continueOauthFlow("ligma", using: network, store: keychain)
            XCTAssertEqual(keychain.getSecureStore("starlight_acess_token"), "d076cc9f3d73a31c13a4840884535755")
        }
    }

    func testAuthenticationAppliesFromKeychain() async throws {
        guard let keychain else { return XCTFail("Keychain is missing.") }
        keychain.setSecureStore("d076cc9f3d73a31c13a4840884535755", forKey: "starlight_acess_token")
        
        let newAuthenticationModule = AuthenticationModule(using: keychain)
        switch newAuthenticationModule.authState {
        case .authenthicated(let token):
            XCTAssertEqual(token, "d076cc9f3d73a31c13a4840884535755")
        default:
            XCTFail("Auth state was not authenticated: \(newAuthenticationModule.authState)")
        }
    }

    func testAuthenticationFlushes() async throws {
        await callNetworkProvider(auth: true) { network, keychain in
            await network.authenticator.signOut(using: network, store: keychain)
            [
                "starlight_client_id",
                "starlight_client_secret",
                "starlight_instance_domain",
                "starlight_acess_token"
            ].forEach { field in
                XCTAssertNil(keychain.getSecureStore(field))
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
