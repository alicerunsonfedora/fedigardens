import Danger 
let danger = Danger()

let PR_THRESHOLD = 20

let editedFiles = danger.git.modifiedFiles + danger.git.createdFiles
if editedFiles.count > 20 {
    warn(
        "This appears to be a big PR. If this PR contains multiple features or tickets, please consider splitting them up for easier review."
    )
}

SwiftLint.lint()
