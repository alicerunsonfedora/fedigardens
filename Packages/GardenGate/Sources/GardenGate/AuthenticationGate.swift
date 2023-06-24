//
//  AuthenticationGate.swift
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
import Combine
import FlowKit
import Foundation

public class AuthenticationGate: ObservableObject {
    public enum AuthenticationError: Error {
        case unitializedGate
        case authorizationInProgress(String)
    }

    public enum State: Equatable, Hashable {
        case initial
        case editing(domain: String)
        case openAuth(domain: String, callback: URL)
        case error(Error)

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .initial:
                hasher.combine("\(State.self)__initial")
            case .editing(let domain):
                hasher.combine("\(State.self)__editing")
                hasher.combine(domain.hashValue)
            case .openAuth(let domain, _):
                hasher.combine("\(State.self)__openAuth")
                hasher.combine(domain)
            case .error(let domainValidationError):
                hasher.combine("\(State.self)__error")
                hasher.combine(domainValidationError.localizedDescription)
            }
        }

        public static func == (lhs: State, rhs: State) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }

    public enum Event {
        case edit(domain: String)
        case getAuthorizationToken
        case reset
    }

    @Published var internalState: State = .initial

    private let app = Alice.OAuth.RegisteredApplication(name: "Fedigardens", website: "https://fedigardens.app")
    private let disallowedDomains: Set<String> = {
        guard let disallowPath = Bundle.module.path(forResource: "Disallow", ofType: "plist") else { return Set() }
        let url = URL(filePath: disallowPath)
        do {
            let data = try Data(contentsOf: url)
            let decoded = try PropertyListDecoder().decode([String].self, from: data)
            return Set(decoded)
        } catch {
            print("Fetch disallow list error: \(error.localizedDescription)")
            return Set()
        }
    }()

    private var auth: Alice.OAuth
    private var network: Alice

    public init(auth: Alice.OAuth = .shared, network: Alice = .shared) {
        self.internalState = .initial
        self.auth = auth
        self.network = network
    }
}

extension AuthenticationGate: StatefulFlowProviding {
    public var state: State { internalState }

    public func emit(_ event: Event) async {
        switch event {
        case .edit(let domain):
            internalState = .editing(domain: domain)
        case .getAuthorizationToken:
            switch internalState {
            case .initial:
                internalState = .error(AuthenticationError.unitializedGate)
            case .editing(let domain):
                if disallowedDomains.contains(domain) {
                    internalState = .error(DomainValidationError.rejected(domain: domain))
                    return
                }
                await auth.startOauthFlow(for: domain, registeredAs: app, using: network) { callback in
                    self.internalState = .openAuth(domain: domain, callback: callback)
                } onBadURL: { _ in
                    self.internalState = .error(DomainValidationError.invalid(domain: domain))
                }
            case .openAuth(let domain, _):
                internalState = .error(AuthenticationError.authorizationInProgress(domain))
            case .error(let error):
                internalState = .error(error)
            }
        case .reset:
            internalState = .initial
        }
    }
}
