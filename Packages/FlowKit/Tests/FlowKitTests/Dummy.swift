//
//  Dummy.swift
//  FlowKitTests
//
//  Created by Marquis Kurt on 24/6/23.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import FlowKit
import SwiftUI

actor DummyFlow: StatefulFlowProviding {
    var state: State { internalState }

    var onStateChange: ((State) -> Void)?
    var stateSubscribers = [((State) -> Void)]()

    private var internalState: State = .initial {
        didSet {
            stateSubscribers.forEach { callback in
                callback(internalState)
            }
        }
    }

    enum State {
        case initial
        case unknown
    }

    enum Event {
        case enterUnknownState
        case reset
    }

    init() {}

    func emit(_ event: Event) async {
        switch event {
        case .enterUnknownState:
            internalState = .unknown
        case .reset:
            internalState = .initial
        }
    }

}

struct DummyView: StatefulView {
    var flow = DummyFlow()

    @State private var someText: String = ""

    var statefulBody: some View {
        Text(someText)
            .padding()
    }

    func stateChanged(_ state: DummyFlow.State) {
        switch state {
        case .initial:
            someText = "Hello, world!"
        case .unknown:
            someText = "Uh oh"
        }
    }
}
