//
//  NotificationType.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/**
 An enumerated representation of the different types of notifications.
 */
public enum NotificationType: String, Codable {

    /// When an account follows the user
    case follow

    /// When an account mentions the user in a post
    case mention

    /// When an account reblogs the user's post
    case reblog

    /// When an account favorites the user's post
    case favourite

    /// When an account is requesting to follow the user
    case followRequest = "follow_request"
}
