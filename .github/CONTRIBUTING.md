# Contributing Guidelines

This document outlines the contributing guidelines and style guides for
the source code in this project.

## File headers

Files in this project should contain the following copytext, which informs
contributors, users, and developers who created the file, when it was
created, and that this file is a part of Codename Shout, licensed under the
CNPLv7+.

```swift
//
//  <Filename>.swift
//  <Module>
//
//  Created by Marquis Kurt on 25/1/22.
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.
```
## Commit messages

Commit messages are formatted to inform other developers and contributors
of the changes made in the commit, why they were made, and what type of
changes were made. All commits should follow the format below, as described:

```
:gitmoji: Brief summary of commit changes

A description that describes the problem or what prompted the change, what
was changed, and why the change was made.

If this solves a particular problem in the bug reporter, you can write a
YouTrack command like below:

^SHU-0 stage Review work Development 5m
```

Gitmojis are used to describe changes quickly when viewing them in GitHub
or summary lists. Please visit https://gitmoji.dev to view what each of
the emojis mean, and what tools can be used to insert the appropriate one
into your Git commit messages.

## Linting conventions

This project includes support for SwiftLint, a utility that enforces
recommended Swift styling practices. While it is not required to install
SwiftLint to build the project, it is highly recommended. The project,
during build, will do the following with SwiftLint:

- Run the linter on all source files and present warnings/errors in Xcode
  after running.
  
It is recommended that you ensure that your source code changes are
compliant with the linting rules as specified.

### Sepcial rules

- Always refer to the project as "Codename Shout", and not "Capstone",
  unless you are referring to the Swift module generated.
- When possible, avoid making a filtered list and iterating over it; use
  the `for x in x where y` format instead.

## Formatting conventions

It is recommended that you run the formatting tool `swiftformat` when you
commit code. A .swiftformat file is provided at the root of the project to
assist you in formatting your source changes to the format of the project.

```
swiftformat .
```
