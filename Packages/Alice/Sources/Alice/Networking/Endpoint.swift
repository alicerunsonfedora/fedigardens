//
//  Endpoint.swift
//  Chica
//
//  Created by Alex Modroño Vara on 16/7/21.
//

import Foundation

/// Reusable base Endpoint struct that allows us to have all the possible API paths in a cleaner way.
/// It is used everytime we try to interact with the fediverse.
///
/// To acess the entire path, access the variable `Endpoint.path`.
///
/// Special thanks to **Thomas Ricouard** for inspiration.
public enum Endpoint {

    //  MARK: - OAUTH
    /* Everything related with registering client applications that can be used to obtain OAuth tokens and authorizing user
     * accounts for interacting with user-level data. */
    
    /// Create a new application to obtain OAuth2 credentials.
    case apps

    /// Confirm that the app's OAuth2 credentials work.
    case verifyAppCredentials

    /// Displays an authorization form to the user. If approved, it will create and return an authorization code, then redirect to the desired redirect_uri, or show the authorization code if urn:ietf:wg:oauth:2.0:oob was requested. The authorization code can be used while requesting a token to obtain access to user-level methods.
    case authorizeUser

    /// Obtain or revoke an access token, to be used during API calls that are not public.
    case token, revokeToken

    //  MARK: - ACCOUNTS
    // Methods concerning user accounts and related information.



    //  MARK: – CREDENTIALS
    // Methods concerning working with an account's credentials

    /// Creates a user and account records. Returns an account access token for the app that initiated the request. The app should save this token for later, and should wait for the user to confirm their account by clicking a link in their email inbox.
    case registerAccount

    /// Test the token of an account works.
    case verifyAccountCredentials

    /// Update the credentials of an account.
    case updateCredentials

    //  MARK: – INFORMATION
    // Methods concerning retrieving an account's related information.
    
    /// View information about a profile.
    case account(id: String)

    /// Retrieve the statuses posted to the given account.
    case accountStatuses(id: String)

    /// Accounts which follow the given account, if network is not hidden by the account owner.
    case accountFollowers(id: String)

    /// Accounts which the given account is following, if network is not hidden by the account owner.
    case accountFollowing(id: String)

    /// Tags featured by this account.
    case accountFeaturedTags(id: String)

    /// User lists that you have added this account to.
    case accountLists(id: String)

    /// Returns an array of IdentityProof
    case accountIdentityProofs(id: String)

   
    //  MARK: – ACTIONS
    // Methods concerning performing actions on accounts.

    /// Follow or unfollow the given account. Can also be used to update whether to show reblogs or enable notifications.
    case followAccount(id: String), unfollowAccount(id: String)

    /// Block or unblock the given account.
    ///
    /// Clients should filter statuses from this account if received (e.g. due to a boost in the Home timeline).
    case blockAccount(id: String), unblockAccount(id: String)

    /// Mute or unmute the given account.
    ///
    /// Clients should filter statuses and notifications from this account, if received (e.g. due to a boost in the Home timeline).
    case muteAccount(id: String), unmuteAccount(id: String)

    /// Add or remove the given account to the user's featured profiles.
    ///
    /// Featured profiles are currently shown on the user's own public profile.
    case pinAccount(id: String), unpinAccount(id: String)

    /// Sets a private note on a user.
    case noteOnAccount(id: String)
    
    // MARK: - COMMUNITY INFORMATION
    // Methods pertaining to information about the current instance (community) they reside in.
    
    /// Information about the current server they reside in.
    case instance
    
    /// A list of of custom emojis this server has registered.
    case customEmojis
    
    /// A list of trending tags with their history.
    case trending

    /// A list of accounts that are visible in the instance's directory.
    case directory


    //  MARK: – GENERAL
    // Methods concerning performing general actions or retrieving general information from accounts.

    /// Find out whether a given account is followed, blocked, muted, etc.
    case generalRelationships

    /// Search for matching accounts by username or display name.
    case search

    /// Retrieves lists that the user has created.
    case lists
    
    // MARK: - TIMELINES AND STATUSES
    // Methods pertaining to interacting with timelines.
    
    /// Get a list of posts from a particular timeline.
    case timeline(scope: TimelineScope)
    
    /// Get the parenst and children to a given status.
    case context(id: String)

    /// The user's notifications.
    case notifications

    /// Post a status to the user's profile, or request a status with a given ID.
    case statuses(id: String? = nil)

    /// The user's saved statuses.
    case bookmarks

    // MARK: - ACTIONS
    // Methods pertaining to actions that can be performed on statuses.

    /// Like or favorite a status.
    /// - Note: This endpoint is spelled with the British spelling to maintain Mastodon API consistency.
    case favourite(id: String), unfavorite(id: String)

    /// Reblog/unreblog a status.
    case reblog(id: String), unreblog(id:String)

    /// Privately save or unsave a status to an account's bookmarks.
    case save(id: String), undoSave(id: String)

    // MARK: - ENDPOINT MAPPING

    /// Full path
    var path: String {
        switch self {
        case .apps:
            return "/api/v1/apps"
        case .verifyAppCredentials:
            return "/api/v1/apps/verify_credentials"
        case .authorizeUser:
            return "/oauth/authorize"
        case .token:
            return "/oauth/token"
        case .revokeToken:
            return "/oauth/revoke"
        case .registerAccount:
            return "/api/v1/accounts"
        case .verifyAccountCredentials:
            return "/api/v1/accounts/verify_credentials"
        case .updateCredentials:
            return "/api/v1/accounts/update_credentials"
        case let .account(id):
            return "/api/v1/accounts/\(id)"
        case let .accountStatuses(id):
            return "/api/v1/accounts/\(id)/statuses"
        case let .accountFollowers(id):
            return "/api/v1/accounts/\(id)/statuses"
        case .instance:
            return "/api/v1/instance"
        case .customEmojis:
            return "/api/v1/custom_emojis"
        case .trending:
            return "/api/v1/trends"
        case .timeline(let scope):
            return scope.path
        case let .context(id):
            return "/api/v1/statuses/\(id)/context"
        case .directory:
            return "/api/v1/directory"
        case .notifications:
            return "/api/v1/notifications"
        case .statuses(let statusId):
            let pathExtension: String = statusId == nil ? "" : "/\(statusId!)"
            return "/api/v1/statuses" + pathExtension
        case .favourite(let statusId):
            return "/api/v1/statuses/\(statusId)/favourite"
        case .unfavorite(let statusId):
            return "/api/v1/statuses/\(statusId)/unfavourite"
        case .reblog(let statusId):
            return "/api/v1/statuses/\(statusId)/reblog"
        case .unreblog(let statusId):
            return "/api/v1/statuses/\(statusId)/unreblog"
        case .save(let statusId):
            return "/api/v1/statuses/\(statusId)/bookmark"
        case .undoSave(let statusId):
            return "/api/v1/statuses/\(statusId)/unbookmark"
        case .lists:
            return "/api/v1/lists"
        case .bookmarks:
            return "/api/v1/bookmarks"
        default: return ""
        }
    }

}
