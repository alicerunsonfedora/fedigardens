# Contribution Guidelines

The following guidelines should be followed when contributing code to ensure that it
follows the standards set out by the FlowKit project. Note that these guidelines are a
living document that gets updated throughout the lifecycle of the project.

**Table of Contents**  
- [Git conventions](#git-conventions)
  - [Flow](#flow)
  - [Commit messages](#commit-messages)
  - [Pull requests](#pull-requests)
- [Code conventions](#code-conventions)
  - [Linting and formatting](#linting-and-formatting)
  - [License headers](#license-headers)

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

### Pull requests

- Pull requests should have an adequate description of the changes being made, and
  any feedback reports it addresses.
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

### License headers

Source files must attach the MPLv2 license header, with any dates written in the
DD/MM/YYYY format. An example is as follows:

```swift
//
//  ExampleFile.swift
//  FlowKit
//
//  Created by Marquis Kurt on 24/6/23.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
```
