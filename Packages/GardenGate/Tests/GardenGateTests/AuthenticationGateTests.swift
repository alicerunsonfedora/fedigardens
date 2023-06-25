//
//  AuthenticationGateTests.swift
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

import Alice
import AliceMockingbird
import FlowKitTestSupport
@testable import GardenGate
import XCTest

final class AuthenticationGateTests: XCTestCase, StatefulTestCase {
    typealias TestableFlow = AuthenticationGate
    var cbString: String {
        "https://hyrma.example/api/v1/apps?client_name=Fedigardens&redirect_uris="
        + "starlight://oauth&scopes=read%20write%20follow%20push&website=https://fedigardens.app"
    }
    var flow: AuthenticationGate?
    var mockKeychain: AliceMockKeychain?
    var provider: Alice?

    override func setUp() async throws {
        let mock = AliceMockKeychain()
        let provider = Alice(using: AliceMockSession.self, with: .init(using: mock))
        mockKeychain = mock
        self.flow = AuthenticationGate(auth: provider.authenticator, network: provider)
    }

    override func tearDown() async throws {
        self.flow = nil
        self.mockKeychain?.flush()
        self.mockKeychain = nil
        self.provider = nil
    }

    func testFlowInitialStateMatches() async throws {
        await withCheckedFlow { current in
            XCTAssertEqual(current.state, .initial)
        }
    }

    func testFlowDispatchEditEvent() async throws {
        let domain = "hyrma.example"
        var domainString = ""
        await withCheckedFlow { current in
            for character in domain {
                domainString += String(character)
                await current.emit(.edit(domain: domainString))
                XCTAssertEqual(current.state, .editing(domain: domainString))
            }
        }
    }

    func testFlowDispatchStartAuthorization() async throws {
        let domain = "hyrma.example"
        let expectation = XCTestExpectation(description: "Network called")
        await withCheckedFlow { current in
            await current.emit(.edit(domain: domain))
            await current.emit(.getAuthorizationToken)
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                expectation.fulfill()
            }
            await self.fulfillment(of: [expectation], timeout: 10)
            XCTAssertEqual(current.state, .openAuth(domain: domain, callback: URL(string: self.cbString)!))
        }
    }

    func testFlowDispatchErrorOnInvalidDomain() async throws {
        let badURL = " "
        let expectation = XCTestExpectation(description: "Network called")
        await withCheckedFlow { current in
            await current.emit(.edit(domain: badURL))
            await current.emit(.getAuthorizationToken)
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                expectation.fulfill()
            }
            await self.fulfillment(of: [expectation], timeout: 10)
            XCTAssertEqual(current.state, .error(DomainValidationError.invalid(domain: badURL)))
        }
    }

    func testFlowDispatchErrorOnRejectedDomain() async throws {
        let badURL = "gab.ai"
        await withCheckedFlow { current in
            await current.emit(.edit(domain: badURL))
            await current.emit(.getAuthorizationToken)
            XCTAssertEqual(current.state, .error(DomainValidationError.rejected(domain: badURL)))
            XCTAssertEqual(
                DomainValidationError.rejected(domain: badURL).message,
                "Fedigardens cannot sign in to gab.ai because the developers cannot verify that this server moderates"
                + " the content posted by its users.")
        }
    }

    func testFlowDispatchErrorOnPrematureAuthorization() async throws {
        await withCheckedFlow { current in
            await current.emit(.getAuthorizationToken)
            XCTAssertEqual(current.state, .error(AuthenticationGate.AuthenticationError.unitializedGate))
        }
    }

    func testFlowDispatchErrorOnInProgressAuthorization() async throws {
        let domain = "hyrma.example"
        let expectation = XCTestExpectation(description: "Network called")
        await withCheckedFlow { current in
            await current.emit(.edit(domain: domain))
            await current.emit(.getAuthorizationToken)
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                expectation.fulfill()
            }
            await self.fulfillment(of: [expectation], timeout: 10)
            XCTAssertEqual(current.state, .openAuth(domain: domain, callback: URL(string: self.cbString)!))

            await current.emit(.getAuthorizationToken)
            XCTAssertEqual(current.state,
                           .error(AuthenticationGate.AuthenticationError.authorizationInProgress(domain)))
        }
    }

    func testFlowDispatchErrorOnAmbushedError() async throws {
        let domain = "hyrma.example"
        let expectation = XCTestExpectation(description: "Network called")
        await withCheckedFlow { current in
            await current.emit(.edit(domain: domain))
            await current.emit(.getAuthorizationToken)
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                expectation.fulfill()
            }
            await self.fulfillment(of: [expectation], timeout: 10)
            XCTAssertEqual(current.state, .openAuth(domain: domain, callback: URL(string: self.cbString)!))

            await current.emit(.getAuthorizationToken)
            XCTAssertEqual(current.state,
                           .error(AuthenticationGate.AuthenticationError.authorizationInProgress(domain)))

            await current.emit(.getAuthorizationToken)
            XCTAssertEqual(current.state,
                           .error(AuthenticationGate.AuthenticationError.authorizationInProgress(domain)))
        }
    }

    func testFlowDispatchReset() async throws {
        let domain = "hyrma.example"
        var domainString = ""
        await withCheckedFlow { current in
            for character in domain {
                domainString += String(character)
                await current.emit(.edit(domain: domainString))
                XCTAssertEqual(current.state, .editing(domain: domainString))
            }
            await current.emit(.reset)
            XCTAssertEqual(current.state, .initial)
        }
    }
}
