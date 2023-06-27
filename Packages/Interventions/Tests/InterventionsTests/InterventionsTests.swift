#if os(macOS)
import AppKit
#else
import UIKit
#endif

@testable import Interventions
import FlowKitTestSupport
import XCTest

struct DummyLinkOpener: InterventionLinkOpener {
    func canOpenURL(_ url: URL) async -> Bool { true }
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool { return true }
}

final class InterventionFlowTests: XCTestCase, StatefulTestCase {
    typealias TestableFlow = InterventionFlow<DummyLinkOpener>

    var flow: InterventionFlow<DummyLinkOpener>?

    override func setUp() async throws {
        self.flow = InterventionFlow(linkOpener: DummyLinkOpener())
    }

    override func tearDown() async throws {
        self.flow = nil
    }

    func testEmitAuthorizationRequest() async throws {
        let initialRequestDate = Date.now
        await emitAndWait(event: .requestIntervention, forPeriod: 2, timeout: 5, message: "Authorization request")
        expectState(matches: .requestedIntervention(initialRequestDate))
    }

    func testEmitAuthorizationCompletion() async throws {
        await withCheckedFlow { [self] currentFlow in
            await emitAndWait(event: .requestIntervention, forPeriod: 2, timeout: 5, message: "Authorization request")
            let context = InterventionAuthorizationContext(allowedTimeInterval: 5, allowedFetchSize: 10)
            let capturedDate = Date.now
            await currentFlow.emit(.authorizeIntervention(capturedDate, context: context))
            expectState(matches: .authorizedIntervention(capturedDate, context: context))
        }
    }

    func testEmitReset() async throws {
        await withCheckedFlow { [self] currentFlow in
            await emitAndWait(event: .requestIntervention, forPeriod: 2, timeout: 5, message: "Authorization request")
            await currentFlow.emit(.reset)
            expectState(matches: .initial)
        }
    }

    func testEmitAuhtorizationFailureFromInvalidState() async throws {
        await emitAndWait(event: .authorizeIntervention(.now, context: .default),
                          forPeriod: 2,
                          timeout: 5,
                          message: "Authorization request")
        expectState(matches: .error(InterventionRequestError.invalidAuthorizationFlowState))
    }

    func testEmitFailureFromBruteForceRequest() async throws {
        await withCheckedFlow { [self] _ in
            let initialRequestDate = Date.now
            await emitAndWait(event: .requestIntervention, forPeriod: 2, timeout: 5, message: "Authorization request")
            await emitAndWait(event: .requestIntervention, forPeriod: 2, timeout: 5, message: "Authorization request")
            expectState(matches: .error(InterventionRequestError.requestAlreadyMade(initialRequestDate)))
        }
    }

    func testEmitFailureAlreadyAuthorized() async throws {
        await emitAndWait(event: .requestIntervention, forPeriod: 2, timeout: 5, message: "Authorization request")
        let context = InterventionAuthorizationContext(allowedTimeInterval: 5, allowedFetchSize: 10)
        let capturedDate = Date.now
        await emitAndWait(event: .authorizeIntervention(capturedDate, context: context),
                          forPeriod: 2,
                          timeout: 5,
                          message: "Complete authorization")
        await emitAndWait(event: .authorizeIntervention(capturedDate, context: context),
                          forPeriod: 2,
                          timeout: 5,
                          message: "Complete authorization")
        expectState(matches: .error(InterventionRequestError.alreadyAuthorized(capturedDate, context: context)))
    }

    func testEmitFailureFromError() async throws {
        await emitAndWait(event: .authorizeIntervention(.now, context: .default),
                          forPeriod: 2,
                          timeout: 5,
                          message: "Authorization request")
        await emitAndWait(event: .authorizeIntervention(.now, context: .default),
                          forPeriod: 2,
                          timeout: 5,
                          message: "Authorization request")
        expectState(matches: .error(InterventionRequestError.invalidAuthorizationFlowState))
    }

    func testEmitFailureFromMissingOneSec() async throws {
        let expectation = XCTestExpectation(description: "Request intervention")
        #if os(macOS)
        let realFlow = InterventionFlow()
        #else
        let realFlow = InterventionFlow()
        #endif
        await realFlow.emit(.requestIntervention)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        await self.fulfillment(of: [expectation], timeout: 5)
        XCTAssertEqual(realFlow.state, .error(InterventionRequestError.oneSecNotAvailable))
    }

    func testEmitDropoutAfterRequestingInterventionWhileAuthorized() async throws {
        await withCheckedFlow { [self] currentFlow in
            await emitAndWait(event: .requestIntervention, forPeriod: 2, timeout: 5, message: "Authorization request")
            let context = InterventionAuthorizationContext(allowedTimeInterval: 5, allowedFetchSize: 10)
            let capturedDate = Date.now
            await currentFlow.emit(.authorizeIntervention(capturedDate, context: context))
            await emitAndWait(event: .requestIntervention, forPeriod: 2, timeout: 5, message: "Authorization request")
            expectState(matches: .authorizedIntervention(capturedDate, context: context))
        }
    }
}
