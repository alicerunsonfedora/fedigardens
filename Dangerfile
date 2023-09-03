pr_file_threshold = 20
suggest_changes = false

edited_files = (git.modified_files + git.created_files)

if edited_files.count > pr_file_threshold
	warn "This appears to be a big merge request." \
		"If this PR contains multiple features or tickets, please consider splitting them up for easier review."
	suggest_changes = true
end

deleted_files = git.deleted_files.count
if deleted_files > pr_file_threshold
	warn "This merge request contains #{deleted_files} files that were deleted."
	suggest_changes = true
end

if edited_files.count > 3 && !edited_files.include?("CHANGELOG.md")
	warn "This merge request does not have an update in the CHANGELOG."
    markdown "If the changelog doesn't have a section for the latest unreleased version, you may create one."
end

warn "Unit tests have been changed." if !edited_files.grep(/Tests/).empty?

if gitlab.mr_body.length < 1
	fail "Please provide a description of what this PR changes."
	markdown <<- MARKDOWN
Per the contribution guidelines:

> - Pull requests should have an adequate description of the changes being made, and
>   any feedback reports it addresses.
> - Pull requests should be properly tagged with the modules it affects, such as
>   Authentication and Frugal Mode.
> - With some execeptions, pull requests should _always_ pass Danger checks and any
>   unit tests attached.
MARKDOWN
    suggest_changes = true
end

random_messages = ["Good on ya!", "Great work!", "Excellent work!", "Good job!", ";^)", "Perfection.", "Congrats!"]
if !suggest_changes
	markdown "Code looks great. " + random_messages.sample
    markdown "Note that a successful Danger check does *not* mean an automatic merge request approval."
end