# Introduction to Flows

Learn the fundamentals of the flow architecture and FlowKit.

## Overview

FlowKit provides a software architecture inspired by reactive/redux architectures and the Composable architecture while
offering a similar structure to architectures such as MVVM and MVC. This article will cover the fundamentals of how
this architecture works, and how it compares to other software architectures you may already be familiar with.

## What does FlowKit solve?

It's important to note the problems that flows and FlowKit attempt to solve before creating a flow for your app. Let's 
consider an app that uses the MVVM architecture, and that you have a view model for a view that  displays a list of
movies. You may have a data model defined for a movie based on a specified API response:

```swift
struct Movie: Identifiable, Hashable {
    var id: UUID
    var title: String
    var posterImage: URL
    var synopsis: String
    ...
}
```

Meanwhile, you may have a view model for this view which houses the data along with any other properties needed for that
view to load. In this example, it is an `ObservableObject` utilizing the Combine framework:

```swift
import Combine

class MovieListViewModel: ObservableObject {
    enum ViewState {
        case initial
        case loading
        case loaded
        case error
    }

    @Published var movies: [Movies] = []
    @Published var viewState: ViewState = .initial
    var error: some Error?

    func fetchMovies(at page: Int) async { ... }
}
```

Additionally, you may have a view in SwiftUI that utilizes this view model to display the movies in question:

```swift
import SwiftUI

struct MovieListView: View {
    @ObservedObject var viewModel = MovieListViewModel()

    var body: some View {
        Group {
            switch viewModel.viewState {
                case .loaded:
                    List {
                        ForEach(viewModel.movies) { movie in
                            ...
                        }
                    }
                ...
            }
        }
        .task {
            await viewModel.fetchMovies(at: 1)
        }
    }
}
```

Ideally, the current architecture will allow you to fetch movies and display them in a list, assuming the view state
follows the happy path and lands on `.loaded`. However, some issues arise when looking at the view model:

```swift
class MovieListViewModel: ObservableObject {
    @Published var movies: [Movies] = []
    @Published var viewState: ViewState = .initial
    var error: some Error?
    ...
}
```

On first glance, it may be difficult to determine the various states this view model can be presented in. While the
`viewState` does provide some clarity, it doesn't really tell us whether the `loaded` state, for example, provides just
the movies or any additional information with it. It's also unclear as to how these states are triggered. What can cause
the view model to go into the `loading` state or the `error`? Without extensive knowledge of the code in the view model,
it isn't all that clear on first glance.

Additionally, the state in the app is completely mutable, meaning that it can be easily manipulated from other sources.
This could potentially cause uninentional side effects, and since the state is already ambiguous, may cause further
confusion and unexpected behavior in our code.

## Introducing flows

Ideally, we'd want our state to be a clearly defined structure, and it should be controlled through the events that take
place in the view model throughout its lifecycle. This is one of the many problems that FlowKit attempts to solve with
the Flow architecture.

A _flow_ in the Flow architecture, like MVVM, is an intermediary layer between your views and models to provide a clean
interface for interacting with and displaying your data. However, unlike MVVM, the state can only be controlled through
a series of events. Views act as a function of state and subscribe to its changes.

![A diagram of the flow architecture](FlowDiagram)

A view can emit an event to the flow, which will perform an action. That action may interact with the model, such as
requesting for data to be stored or sending data to it. The action will then update the state of the flow, which is used
to derive the view's appearance. State can only be updated through the emission of an event.

> Note: Flows are actors, which guarantees that state can not be modified or read in such as way that causes a data
> race to occur. Events are emitted asynchronously, and any work done to respond to an event are done on the actor.
> Other actors cannot manipulate the state of a flow, and views that subscribe to state changes will be notified on the
> main thread through the main actor.

Let's revisit the movies example from earlier. Rather than using an `ObservableObject`, we can represent the view model
as a flow using ``StatefulFlowProviding``:

```swift
import FlowKit

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
    private var internalState = State.initial {
        didSet {
            stateSubscribers.forEach { callback in callback(internalState) }
        }
    }

    private func getMovies(at page: Int) async -> Result<[Movie], Error>
    ...
}
```

In the movie list flow, the state now becomes apparent: an `initial` state, where nothing is loaded, a `loaded` state,
which provides the list of movies we want, and an `errored` state, which provides any errors that might have occurred.
Note that `state` is a computed property which cannot be directly modified.

The ``StatefulFlowProviding/emit(_:)`` is used to emit events, which may look something like this for our movie flow:

```swift
public func emit(_ event: Event) async {
    switch event {
        case .fetchMovies(let page):
            await loadMovies(page: page)
        case .reset:
            internalState = .initial
    }
}

private func loadMovies(page: Int) async {
    switch getMovies(at: page) {
        case .success(let movies):
            internalState = .loaded(movies)
        case .failure(let error):
            internalState = .errored(error)
    }
}
```

Notice that the paths for state are clearly defined in the emit method, allowing a developer to better understand the
flow of events. Whenever the state is updated, all its subscribers in ``StatefulFlowProviding/stateSubscribers`` are
notified.

### Stateful views with flows

Our movie list flow can utilize ``StatefulView`` to then receive these updates:

```swift
import FlowKit
import SwiftUI

struct MovieListView: StatefulView {
    typealias FlowProvider = MovieListFlow

    @State private var movies = [Movies]()
    @State private var errored = false
    @State private var movieError: Error?

    var flow = MovieListFlow()

    var statefulBody: some View {
        List {
            ForEach(movies) { movie in
                ...
            }
        }
        .alert(isPresented: $displayError, error: movieError) { ... }
        .task {
            await flow.emit(.fetchMovies(page: 1))
        }
    }

    func stateChanged(_ state: MovieListFlow.State) {
        switch state {
            case .initial:
                movies = []
                movieError = nil
                errored = false
            case .loaded(let newMovies):
                movies = newMovies
                movieError = nil
                errored = false
            case .errored(let error):
                movieError = error
                errored.toggle()
        }
    }
}
```

You may notice some things with our new view. First, some content that we have stored in our original view model such
as the error and list of movies appear here as well. Because flows are actors, and any updates to a view must occur on
the main thread, these properties are resurfaced in the view so that they can be displayed. However,
``StatefulView/stateChanged(_:)`` makes it clear which parts of the view are updated based on its current state.

> Important: Never call ``StatefulFlowProviding/emit(_:)`` inside of the ``StatefulView/stateChanged(_:)`` method, as
> this may cause an infinite loop of state updates.

Next, you might notice that the contents of our view are defined in ``StatefulView/statefulBody-swift.property`` rather
than the standard SwiftUI body. ``StatefulView/statefulBody-swift.property`` provides the main content of a SwiftUI view
while also automatically setting up subscribers to the view's flow.

> Important: When creating a flow using ``StatefulView``, never define the `body` property. ``StatefulView`` takes care
> of view registration and subscriptions for you, and defining `body` manually may cause unexpected behavior.

### Dealing with side effects

The flow architecture is designed in such a way where any unintentional side effects should not occur within a flow.
Remember that a flow's state can only be updated through an event emitted to that flow's actor. Any subscriptions to a
flow's state changes should be done deliberately, and without emitting another event. Ideally, a flow's 
``StatefulFlowProviding/emit(_:)`` should produce no side effects, only relying on the event as its source of truth.
