//
//  CustomStringConvertible.swift
//
//
//  Created by Alex Modroño Vara on 14/7/21.
//

import Foundation

/// Allows to easily debug methods.
public extension CustomStringConvertible {
    var description: String {
        var description = "========= \(type(of: self)) =========".uppercased()
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\n\(propertyName): \(child.value)"
            }
        }
        description += "\n====== END OF \(type(of: self)) ======".uppercased()
        return description
    }
}
