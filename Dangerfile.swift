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

let PR_THRESHOLD = 20 // swiftlint:disable:this identifier_name

let editedFiles = danger.git.modifiedFiles + danger.git.createdFiles
if editedFiles.count > 20 {
    warn(
        "This appears to be a big PR. If this PR contains multiple features or tickets, please "
        + "consider splitting them up for easier review."
    )
}

SwiftLint.lint()
