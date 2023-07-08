# Testing Flows

Write predictable unit tests for your flows.

## Overview

Flows in FlowKit have been designed with testability in mind, allowing for more predictable results in a flow. FlowKit
provides a test support package, FlowKitTestSupport, for aiding in writing predictable unit tests.

### Why write unit tests?

Writing unit tests for flows helps ensure that behavior is both predictable and expected whenever an event is emitted or
a state changes. While unit tests are not required for flows, it is highly recommended to add them. Most flows in
Fedigardens are written using the test-driven development approach, where the tests for the flows are written before the
flows themselves.

As an example, we will write unit tests for the movie list flow introduced in <doc:Introduction-to-Flows>:

```swift
public actor MovieListFlow: StatefulFlowProviding {
    public enum State: Equatable, Hashable {
        case initial
        case loaded([Movies])
        case errored(Error)
    }

    public enum Event {
        case fetchMovies(page: Int)
        case reset
    }

    public var state: State { internalState }
    public var stateSubscribers = [((State) -> Void)]()
    private var provider: MovieNetworkProvider
    
    public init(provder: MovieNetworkProvider)
    ...
}
```

Note that the flow has been slightly modified to allow a network provider to be added as a dependency that can be
injected.

## Stateful test cases

FlowKitTestSupport provides a single protocol for handling test cases with a flow that can be tested:
`StatefulTestCase`. `StatefulTestCase` is a special type of `XCTestCase` that can test for flow changes in an efficient
manner, without writing any additional boilerplate code.

To start, we can create a test case using XCTest and have it conform to `StatefulTestCase`, along with filling in the
`setUp` and `tearDown` methods to create and destroy the flow:

```swift
import FlowKitTestSupport
import XCTest
@testable import MoviesApp

class MovieListFlowTests: XCTestCase, StatefulTestCase {
    typealias TestableFlow = MovieListFlow
    
    var flow: MovieListFlow?
    
    override func setUp() async throws {
        flow = MovieListFlow(provider: MockMovieListProvider())
    }

    override func tearDown() async throws {
        flow = nil
    }
}
```

### Testing for state matches

`StatefulTestCase` provides helper methods to check the state of a flow at any given point, taking actor access into
account. For example, writing a test for checking the initial state can be accomplished using the
`expectState(matches:)` method:

```swift
func testMovieFlowInitialStateSetup() async throws {
    await expectState(matches: .initial, message: "Setup is incorrect.")
}
```

This is equivalent of using `XCTAssertEqual` without needing to write the boilerplate to wait for the current state:

```swift
func testMovieFlowInitialStateSetup() async throws {
    let currentState = await flow?.state
    XCTAssertEqual(currentState,
                   MoveListFlow.State.initial,
                   message: "Setup is incorrect.")
}
```

Likewise, the opposite can be written with `expectState(doesNotMatch:)`.

### Ensuring proper setup

If a test requires that `flow` is fully initialized, the `withCheckedFlow` method can be called. Note that other calls
such as `expectState(matches:)` will still work in the closure, but it will not take into account the current flow.

```swift
func testSomeFlowChanges() async throws {
    await withCheckedFlow { currentFlow in
        await currentFlow.emit(.reset)
        ...
    }
}
```

### Waiting on state changes

Some flows may take time for a state to be properly updated after emitting an event, such as when waiting for a network
call. `emitAndWait` can be used for these cases, which will wait for a period of time before performing any other checks
in the test function.

```swift
func testMoviesAreFetched() async {
    await emitAndWait(
        .fetchMovies(page: 1),
        forPeriod: 5,
        timeout: 10,
        message: "Movies fetched.")
    await expectState(matches: .loaded(...))
    if case let .loaded(movies) = await flow?.state {
        XCTAssertEqual(movies.first?.title, "The Red Baron")
    }
}
```

Internally, this sets up an XCTestExpectation that fulfills after the period of time specified. After waiting for the
expectation to be fulfilled, execution of the test resumes.
