//
//  Dummy.swift
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

import FlowKit
import SwiftUI

class DummyFlow: StatefulFlowProviding {
    var state: State { internalState }

    var onStateChange: ((State) -> Void)?

    private var internalState: State = .initial {
        didSet { onStateChange?(internalState) }
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
