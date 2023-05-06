//
//  File.swift
//
//
//  Created by Marquis Kurt on 2/12/23.
//

import Foundation

/// A reference type that houses a wrapped element.
/// This is communly used in scenarios where some value types might have recursive stored properties, such as
/// ``Account``.
///
/// The implementation was pulled from Sweeper on StackOverflow:
/// https://stackoverflow.com/questions/73315816/swift-codable-struct-recursively-containing-itself-as-property
public class Box<WrappedElement: Codable>: Codable {
    /// The wrapped value this box houses.
    public let wrappedValue: WrappedElement

    public required init(from decoder: Decoder) throws {
        wrappedValue = try WrappedElement(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}
