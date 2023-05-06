//
//  File.swift
//
//
//  Created by Marquis Kurt on 2/12/23.
//

import Foundation

extension Endpoint {
    /// The endpoint's API path.
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
        case .account(let id):
            return "/api/v1/accounts/\(id)"
        case .accountStatuses(let id):
            return "/api/v1/accounts/\(id)/statuses"
        case .accountFollowers(let id):
            return "/api/v1/accounts/\(id)/statuses"
        case .instance:
            return "/api/v1/instance"
        case .instanceBlocks:
            return "/api/v1/instance/domain_blocks"
        case .customEmojis:
            return "/api/v1/custom_emojis"
        case .trending:
            return "/api/v1/trends"
        case .timeline(let scope):
            return scope.path
        case .context(let id):
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
        case .generalRelationships:
            return "/api/v1/accounts/relationships"
        case .followAccount(let accountId):
            return "/api/v1/accounts/\(accountId)/follow"
        case .unfollowAccount(let accountId):
            return "/api/v1/accounts/\(accountId)/unfollow"
        case .muteAccount(let accountId):
            return "/api/v1/accounts/\(accountId)/mute"
        case .unmuteAccount(let accountId):
            return "/api/v1/accounts/\(accountId)/unmute"
        case .blockAccount(let accountId):
            return "/api/v1/accounts/\(accountId)/block"
        case .unblockAccount(let accountId):
            return "/api/v1/accounts/\(accountId)/unblock"
        case .followTag(let tag):
            return "/api/v1/tags/\(tag)/follow"
        case .unfollowTag(let tag):
            return "/api/v1/tags/\(tag)/unfollow"
        case .followedTags:
            return "/api/v1/followed_tags"
        case .blockedServers:
            return "/api/v1/domain_blocks"
        case .search:
            return "/api/v2/search"
        case .trendingStatuses:
            return "/api/v1/trends/statuses"
        case .votePoll(let id):
            return "/api/v1/polls/\(id)/votes"
        default: return ""
        }
    }
}
