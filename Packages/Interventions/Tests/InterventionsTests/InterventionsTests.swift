@testable import Interventions
import FlowKitTestSupport
import XCTest

final class InterventionFlowTests: XCTestCase, StatefulTestCase {
    typealias TestableFlow = InterventionFlow

    var flow: InterventionFlow?

    override func setUp() async throws {
        self.flow = InterventionFlow()
    }

    override func tearDown() async throws {
        self.flow = nil
    }

    func testEmitAuthorizationRequest() async throws {
        await withCheckedFlow { currentFlow in
            let initialRequestDate = Date.now
            await currentFlow.emitAndWait(event: .requestIntervention,
                                          in: self,
                                          forPeriod: 2,
                                          timeout: 5,
                                          message: "Authorization request")
            currentFlow.expectState(matches: .requestedIntervention(initialRequestDate))
        }
    }

    func testEmitAuthorizationCompletion() async throws {
        await withCheckedFlow { currentFlow in
            await currentFlow.emitAndWait(event: .requestIntervention,
                                          in: self,
                                          forPeriod: 2,
                                          timeout: 5,
                                          message: "Authorization request")
            let context = InterventionAuthorizationContext(allowedTimeInterval: 5, allowedFetchSize: 10)
            let capturedDate = Date.now
            await currentFlow.emit(.authorizeIntervention(capturedDate, context: context))
            currentFlow.expectState(matches: .authorizedIntervention(capturedDate, context: context))
        }
    }

    func testEmitReset() async throws {
        await withCheckedFlow { currentFlow in
            await currentFlow.emitAndWait(event: .requestIntervention,
                                          in: self,
                                          forPeriod: 2,
                                          timeout: 5,
                                          message: "Authorization request")
            await currentFlow.emit(.reset)
            currentFlow.expectState(matches: .initial)
        }
    }
}
