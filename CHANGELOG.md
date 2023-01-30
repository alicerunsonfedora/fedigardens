# Fedigardens Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

<!--
If you need to list changes to this changelog but there isn't an entry for it, create one using the following format:

## [Unreleased] - Date Pending

And list your changes under that.
-->

## [1.0-24 (beta)] - 30/1/2023

### Subscribed Tags
Ever want to catch up on statuses tagged with a specific hashtag? Subscribed Tags is the feature you're looking for! Easily follow and unfollow tags right from the sidebar or in the More tab on iPhone; just tap the plus icon and select "New Subscribed Tag..."

### Settings Overhaul
Settings has been completely overhauled this release with some brand-new settings!
- **Character Limits**: Change the character limit to match your instance, or turn it off altogether.
- **Focused Timeline**: Streamline any of your timelines with Focused Timelines. Focused Timelines will automatically place reblogged content or replies to existing statuses in a separate column for you, letting you see the content that matters most to you.
- **Privacy Levels**: Set the default visibility levels for when you write a new status, reply to someone else, or even quote a status.
- **Blocked Instances**: Add or remove instances you'd like to block easily with a quick and easy-to-use interface.

### Search
Trying to look for a fellow friend or colleague? Want to see what's trending on your instance? Look no further than the new Search page! Easily search for people, statuses, and tags, and get recommendations right on the search page. When searching for tags, you can even see the activity history and subscribe to that tag.

### Other general changes
- Fixes a bug where interventions were too persistent and ignored the user's preferences in one sec.
- Updates composer window activation to be more consistent with the Mail app.
- Improves the character counting algorithm in the composer.


## [1.0-14 (beta)] - 15/1/2023

### Interventions
Fedigardens has partnered with [one sec](https://one-sec.app) to provide healthy interventions[^1]! Receive breathing exercises whenever you perform certain actions to give you a moment to reflect and confirm whether you want to perform that action. This can be customized in **Settings &rsaquo; Interventions** and in one sec.

### New Design for iPhone
Fedigardens has been redesigned on iPhone with a brand-new tab layout! Many interactions have been re-added to the iPhone version, making it easier to favorite and reblog statuses.

### Improved Composer
The composer has received some improvements and a brand-new look! Mentions are now in a separate "To/Cc" field, and the counter now properly reflects the number of characters remaining. Additionally, the text field to add a content warning when "Mark as Sensitive" is turned on is now placed under the toggle, instead of below the composer's text editor. Replies are now automatically set to the _unlisted_ visibility as well.

### Tags in Replies Warning
Fedigardens is deisnged to be as humane and discussion-driven as possible. Such designs include making sure content is shared with consent of the author. This version will now include a warning whenever you include a hashtag in a reply, reminding you to get consent from the person you're replying to first:

> **⚠️ You have hashtags in your reply.**  
> Remember to respect the person you are replying to, and refrain from adding hashtags for reach without consent. Learn more...

You can learn more about this change on the support page at https://fedigardens.app/support/#tags-in-replies.

### Profiles
Finally, you can view authors' profiles in-app! In the overflow menu on a status (or with the new *Profiles* toolbar item on iPad), you can tap "View Profile" for any of the authors of a status (including reblogged and quoted) to view a beautiful new page that displays information about that user. You can even follow, mute, and mention/message that user right from the page.

### Quotes
Quotes have gotten smarter in this release of Fedigardens. Fedigardens can now detect other quote styles such as those from [Ice Cubes](https://github.com/Dimillian/IceCubesApp), [Re: Toot](https://retoot.app), and generic links to Mastodon posts, and it will display those quotes as if they were using Fedigardens's format.

### Interactions
Keep up with active conversations with the new Interactions page, which shows you statuses that you've been mentioned in, or replies from other people in the fediverse.

### Other General Changes
- Author names and status content now properly display custom emojis, where applicable.
- When performing various actions such as favoriting, reblogging, or following a person, you now receive visual feedback with droplets.
- You can now view previous statuses in a thread by tapping on "Show previous conversation..." in the status detail view.
- Disallow list has been updated.
- Polls have been redesigned in the status detail view to be more visually consistent.
- Tapping on "Send Feedback.." in **Settings &rsaquo; About** now opens the composer to the Fedigardens account at indieapps.space.
- Localizations have been updated and terminology is now more consistent.
- Profile pictures of rebloggers on statuses in a timeline list view are no longer displayed erroneously.
- The status detail view page should no longer display the previous content when fetching a new status, and animations should be smoother.
- Settings has been redesigned with new categories and a top-level layout.

## [1.0-1 (beta)] - 1/1/2023

Initial release of Fedigardens.

[^1]: Interventions requires Fedigardens 1.0 (14) or later, and one sec 3.4 (161) or later.
