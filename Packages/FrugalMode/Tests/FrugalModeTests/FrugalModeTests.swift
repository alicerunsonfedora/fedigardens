import FlowKitTestSupport
@testable import FrugalMode
import XCTest

final class FrugalModeFlowTests: XCTestCase, StatefulTestCase {
    typealias TestableFlow = FrugalModeFlow

    var flow: FrugalModeFlow?

    override func setUp() async throws {
        flow = FrugalModeFlow()
    }

    override func tearDown() async throws {
        flow = nil
    }

    func testEmitCheckedOverrides() async throws {
        await withCheckedFlow { currentFlow in
            await currentFlow.emit(.checkOverrides)
            await self.expectState(matches: .userDefaults)
        }
    }

    func testEmitReset() async throws {
        let expectation = XCTestExpectation(description: "Wait finished.")
        await withCheckedFlow { currentFlow in
            await currentFlow.emit(.checkOverrides)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                expectation.fulfill()
            }
            await self.fulfillment(of: [expectation], timeout: 10)
            await currentFlow.emit(.reset)
            await self.expectState(matches: .initial)
        }
    }
}
