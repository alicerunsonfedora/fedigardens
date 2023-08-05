# FlowKit

FlowKit is a framework that provides developers several tools for developing apps with a
simplified actor-based architecture with controlled state. FlowKit works hand in hand with
Swift concurrency and SwiftUI to create stateful flows and views, and it extends XCTest to
allow developers to write meaningful and predictable unit tests.

## Getting started

FlowKit is a Swift package for the Swift Package Manager and can be added through Xcode.

### Use in a Swift package

Add the following to your Package.swift file:

```swift
    dependencies: [
        .package(url: "https://github.com/alicerunsonfedora/flowkit", from: "0.1.0"),
    ]
```

### Build from source

**Required Tools**:

- Xcode 15 or later
- macOS 13.0 or later

Clone the repository using `git clone` or `gh repo clone` then run `swift build` in the
root of the project.

## License

FlowKit is licensed under the Mozilla Public License, v2.0. You can read your rights
in the LICENSE file provided or by obtaining it at https://www.mozilla.org/en-US/MPL/2.0/.

