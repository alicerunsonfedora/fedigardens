@testable import Interventions
import FlowKitTestSupport
import XCTest

struct DummyLinkOpener: InterventionLinkOpener {
    func canOpenURL(_ url: URL) async -> Bool { true }
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any]) async -> Bool { return true }
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
        await withCheckedFlow { [self] _ in
            let initialRequestDate = Date.now
            await emitAndWait(event: .requestIntervention, forPeriod: 2, timeout: 5, message: "Authorization request")
            expectState(matches: .requestedIntervention(initialRequestDate))
        }
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
}
