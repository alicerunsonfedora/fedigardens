# Fedigardens Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

<!--
If you need to list changes to this changelog but there isn't an entry for it, create one using the following format:

## [Unreleased] - Date Pending

And list your changes under that.
-->

## [Unreleased] - Date Pending

- Updates the backend logic for setting and accessing user defaults.
- Updates modules with FlowKit to support actors and concurrency.

## [1.0-53 (beta)] - 3/7/23

- Disables predictive text on the authentication screen.
- Updates the authentication, frugal mode, and interventions modules with FlowKit.
- Adds a clear button and "Done" accessory to the authentication text field.
- Autohides the Fedigardens logo when actively editing text in the authentication screen.

## [1.0-40 (beta)] - 8/5/23
- (FGD-43) Adds a new setting "Prefer Matrix Conversations" which will start Matrix conversations with fediverse people
  that have the "Matrix: (Matrix ID)" field in their bio with a valid Matrix ID. This setting applies in profile pages
  and the profile menu in a discussion detail view.
- (FGD-42) Adds a new "Join Our Matrix Room" section in the About page, which links to #fedigardens:one.ems.host.
- When viewing profiles, the profile stats before the biography are shown/hiiden per the Show Statistics preference.
- Adds a new Frugal Mode setting to use Mastodon more frugally by limiting what is loaded from the network.
- Adds an option in Settings > Viewing to adjust the number of lines in a status preview in a timeline.
- Adds a new "Next Page"/"Load More" button to load more content upon request.

## [1.0-35 (beta)] - 15/3/23

- (FGD-39) Adds a new "Show User Handle In Timeline" toggle in Settings > Viewing that toggles whether a full user
  handle is displayed in the timeline list.
- Renames "instance" to "community server" or "server", and "status" to "discussion".
- Adds minor UI/UX tweaks to work better with Dynamic Type and other accessibility features.
- Improves the video playing experience for discussions with attachments.

## [1.0-34 (beta)] - 4/3/23

- (FGD-22) Shows an alert if Alice cannot connect to the provided instance due to invalid characters.
- Renamed Feedback Portal instances to Raceway.

## [1.0-33 (beta)] - 13/2/23

### Composer Updates
Composer has received some new powers this release. You can now select your status's language, create polls for others
to vote on, and use keyboard shortcuts to trigger actions more easily. On top of that, you can now edit existing
statuses quite easily with the new Edit button on statuses you wrote!

### Attachments
Ever wanted to see pictures your friend posted in better detail? The new attachments view now lets you do this! View
and share attachments easily and safely by tapping on the paperclip icon in the toolbar of any status you're viewing to
activate the new experience.

### Other general changes
- (FGD-33) Adds the ability to vote on and create/edit polls.
- Updated design of polls that have either expired or the user has already voted on using Swift Charts.
- Adds ability to see instance-wide blocked servers in blocklist page (**Settings &rsaquo; Blocked Instances &rsaquo;
  View Instance-wide Blocks**).
- Updates Alice models to include newer API features and remove unused keys.

## [1.0-24 (beta)] - 30/1/2023

### Subscribed Tags
Ever want to catch up on statuses tagged with a specific hashtag? Subscribed Tags is the feature you're looking for!
Easily follow and unfollow tags right from the sidebar or in the More tab on iPhone; just tap the plus icon and select
"New Subscribed Tag..."

### Settings Overhaul
Settings has been completely overhauled this release with some brand-new settings!
- **Character Limits**: Change the character limit to match your instance, or turn it off altogether.
- **Focused Timeline**: Streamline any of your timelines with Focused Timelines. Focused Timelines will automatically
  place reblogged content or replies to existing statuses in a separate column for you, letting you see the content that
  matters most to you.
- **Privacy Levels**: Set the default visibility levels for when you write a new status, reply to someone else, or even
  quote a status.
- **Blocked Instances**: Add or remove instances you'd like to block easily with a quick and easy-to-use interface.

### Search
Trying to look for a fellow friend or colleague? Want to see what's trending on your instance? Look no further than the
new Search page! Easily search for people, statuses, and tags, and get recommendations right on the search page. When
searching for tags, you can even see the activity history and subscribe to that tag.

### Other general changes
- Fixes a bug where interventions were too persistent and ignored the user's preferences in one sec.
- Updates composer window activation to be more consistent with the Mail app.
- Improves the character counting algorithm in the composer.


## [1.0-14 (beta)] - 15/1/2023

### Interventions
Fedigardens has partnered with [one sec](https://one-sec.app) to provide healthy interventions[^1]! Receive breathing
exercises whenever you perform certain actions to give you a moment to reflect and confirm whether you want to perform
that action. This can be customized in **Settings &rsaquo; Interventions** and in one sec.

### New Design for iPhone
Fedigardens has been redesigned on iPhone with a brand-new tab layout! Many interactions have been re-added to the
iPhone version, making it easier to favorite and reblog statuses.

### Improved Composer
The composer has received some improvements and a brand-new look! Mentions are now in a separate "To/Cc" field, and the
counter now properly reflects the number of characters remaining. Additionally, the text field to add a content warning
when "Mark as Sensitive" is turned on is now placed under the toggle, instead of below the composer's text editor.
Replies are now automatically set to the _unlisted_ visibility as well.

### Tags in Replies Warning
Fedigardens is deisnged to be as humane and discussion-driven as possible. Such designs include making sure content is
shared with consent of the author. This version will now include a warning whenever you include a hashtag in a reply,
reminding you to get consent from the person you're replying to first:

> **⚠️ You have hashtags in your reply.**  
> Remember to respect the person you are replying to, and refrain from adding hashtags for reach without consent. Learn more...

You can learn more about this change on the support page at https://fedigardens.app/support/#tags-in-replies.

### Profiles
Finally, you can view authors' profiles in-app! In the overflow menu on a status (or with the new *Profiles* toolbar
item on iPad), you can tap "View Profile" for any of the authors of a status (including reblogged and quoted) to view a
beautiful new page that displays information about that user. You can even follow, mute, and mention/message that user
right from the page.

### Quotes
Quotes have gotten smarter in this release of Fedigardens. Fedigardens can now detect other quote styles such as those
from [Ice Cubes](https://github.com/Dimillian/IceCubesApp), [Re: Toot](https://retoot.app), and generic links to
Mastodon posts, and it will display those quotes as if they were using Fedigardens's format.

### Interactions
Keep up with active conversations with the new Interactions page, which shows you statuses that you've been mentioned
in, or replies from other people in the fediverse.

### Other General Changes
- Author names and status content now properly display custom emojis, where applicable.
- When performing various actions such as favoriting, reblogging, or following a person, you now receive visual feedback
  with droplets.
- You can now view previous statuses in a thread by tapping on "Show previous conversation..." in the status detail
  view.
- Disallow list has been updated.
- Polls have been redesigned in the status detail view to be more visually consistent.
- Tapping on "Send Feedback.." in **Settings &rsaquo; About** now opens the composer to the Fedigardens account at
  indieapps.space.
- Localizations have been updated and terminology is now more consistent.
- Profile pictures of rebloggers on statuses in a timeline list view are no longer displayed erroneously.
- The status detail view page should no longer display the previous content when fetching a new status, and animations
  should be smoother.
- Settings has been redesigned with new categories and a top-level layout.

## [1.0-1 (beta)] - 1/1/2023

Initial release of Fedigardens.

[^1]: Interventions requires Fedigardens 1.0 (14) or later, and one sec 3.4 (161) or later.
