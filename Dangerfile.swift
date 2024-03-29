//
//  Dangerfile.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Danger
let danger = Danger()

var suggestsChanges = false

// MARK: - Configuration Variables

let PR_FILE_THRESHOLD = 20 // swiftlint:disable:this identifier_name

// MARK: - Big PR check

let editedFiles = danger.git.modifiedFiles + danger.git.createdFiles
if editedFiles.count > PR_FILE_THRESHOLD {
    warn("This appears to be a big PR. If this PR contains multiple features or tickets, please "
         + "consider splitting them up for easier review.")
    suggestsChanges = true
}

// MARK: - Deleted file count

if danger.git.deletedFiles.count > PR_FILE_THRESHOLD {
    warn("This PR contains \(danger.git.deletedFiles.count) files that were deleted.")
    suggestsChanges = true
}

// MARK: - Changelog update missing

if editedFiles.count > 1, !editedFiles.contains("CHANGELOG.md") {
    warn("This PR does not have an update in the CHANGELOG.")
    markdown("If the changelog doesn't have a section for the latest unreleased version, you may create one.")
    suggestsChanges = true
}

// MARK: - Test Changes
let tests = editedFiles.filter { filename in filename.contains("Tests") }

if !tests.isEmpty { warn("Unit tests have been changed.") }

// MARK: - GitHub PR changes

if danger.github.pullRequest.body?.isEmpty != false {
    fail("Please provide a description of what this PR changes.")
    markdown("""
Per the contribution guidelines:

> - Pull requests should have an adequate description of the changes being made, and
>   any feedback reports it addresses.
> - Pull requests should be properly tagged with the modules it affects, such as
>   Authentication and Frugal Mode.
> - With some execeptions, pull requests should _always_ pass Danger checks and any
>   unit tests attached.
""")
    suggestsChanges = true
}

if danger.github.pullRequest.draft == true {
    message("PR is a draft.")
}

// MARK: - SwiftLint

let linterWarnings = SwiftLint.lint(configFile: ".swiftlint.yml")
if !linterWarnings.isEmpty {
    suggestsChanges = true

    let warnings = linterWarnings.filter { $0.severity == .warning }
    let errors = linterWarnings.filter { $0.severity == .error }
    if !errors.isEmpty || warnings.count > 20 {
        fail("Please run SwiftLint locally and resolve any errors or warnings.")
    }
}

// MARK: - Congratulatory message

let randomCongraulatoryMessages = [
    "Good on ya!", "Great work!", "Excellent work!", "Good job!", ";^)", "Perfection.", "Congrats!"
]
if !suggestsChanges {
    markdown("Code looks great. " + (randomCongraulatoryMessages.randomElement() ?? "Good job!"))
    markdown("Note that a successful Danger check does *not* mean an automatic PR approval.")
}
