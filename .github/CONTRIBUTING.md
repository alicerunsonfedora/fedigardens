# Contribution Guidelines

The following guidelines should be followed when contributing code to ensure that it
follows the standards set out by the Fedigardens project. Note that these guidelines
are a living document that gets updated throughout the lifecycle of the project.

**Table of Contents**  
- [Git conventions](#git-conventions)
  - [Flow](#flow)
  - [Commit messages](#commit-messages)
  - [Pull requests](#pull-requests)
- [Code conventions](#code-conventions)
  - [Linting and formatting](#linting-and-formatting)
  - [Performance](#performance)
  - [License headers](#license-headers)
- [Module conventions](#module-conventions)
  - [Testing](#testing)
  - [Architecture](#architecture)
  - [Views](#views)

## Git conventions

### Flow

- **Git branches should be aptly named and categorized by domain.** For example, a
  new feature to be added should be named as `feat/feature-name`, bug fixes with
  `bugfix/bug-summary`, and other tasks with `chore/task-summary`.
- **Rebasing is preferred over merging.** Unless it is critically necessary for a
  merge commit to be made, changes should be rebased to keep a clean history.

### Commit messages

Commit messages use the following convention:

```commitmsg
:gitmoji: Summary of changes (50 characters)

A lengthier description of these changes appear here, and they wrap
around the 72 character mark. The description should indicate what
changes were made, along with the reasoning as to why those changes
were made, if possible.
```

More information on Gitmoji can be found at https://gitmoji.dev.

- Note: For commits relating to Xcode Cloud where any existing emoji doesn't
  neatly define the type of commit, use the `:cloud:` :cloud: emoji instead.

### Pull requests

- Pull requests should have an adequate description of the changes being made, and
  any feedback reports it addresses.
- Pull requests should be properly tagged with the modules it affects, such as
  Authentication and Frugal Mode.
- With some execeptions, pull requests should _always_ pass Danger checks and any
  unit tests attached.

## Code conventions

### Linting and formatting

- **Swift source files should produce no linting errors, and minimal warnings.**
  Some warnings such as opening braces on a new line may be ignored in certain
  isolated cases.
- **Swift source files should be formatted using the SwiftFormat settings.**
  Indentation should also match what Xcode produces by pressing Ctrl + I on the
  keyboard.

### Performance

Fedigardens aims to be as performant as possible within the bounds of its modules
and technologies used. Ideally, changes that are made should be consistent with its
current performance or better. If there exist operations that may negatively impact
performance and are not critically necessary for operation, consider having those
operations respect the Frugal Mode setting, running only if Frugal Mode is off.

### License headers

Source files must attach the CNPL license header, with any dates written in the
DD/MM/YYYY format. An example is as follows:

```swift
//
//  ExampleFile.swift
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
```

## Module conventions

### Testing

Modules in the app must provide their own unit tests and provide sufficient coverage
of flows or other business logic. Tests must be runnable through the Fedigardens
test plan.

For any tests that are modified, they should be done in such a way that does not
break other tests or, if breakage is necessary, that the tests better reflect the
functionality being tested.

### Architecture

Modules should follow the Flow architecture outlined in the FlowKit package. States
should be immutable and reflective of the different paths a flow can represent.
Updates must be done asynchronously and in a fashion that prevents data races or
other concurrency issues.

More information on how flows should be written can be found in the FlowKit
documentation.

### Views

Modules should supply their own views that incorporate into the flows they provide.
Views should be designed according to the specifications outlined in the Apple Human
Interface Guidelines. When possible, views should also have any pieces of text be
localizable. Views should also remain accessible, accounting for technologies such
as VoiceOver, Voice Control, and Guided Access.