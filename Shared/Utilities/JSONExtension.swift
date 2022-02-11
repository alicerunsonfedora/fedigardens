// 
//  JSONExtension.swift
//  Capstone
//
//  Created by Marquis Kurt on 11/2/22.
//
//  This file is part of Capstone.
//
//  Capstone is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Capstone comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

extension JSONDecoder {

    /// Decode a JSON file located in a bundle's resources to a specified `Decodable` struct.
    /// - Parameter resourcePath: The name of the resource to decode.
    static func decodeFromResource<T: Decodable>(from resourcePath: String) throws -> T? {
        var content: T? = nil
        
        if let bundleResourcePath = Bundle.main.path(forResource: resourcePath, ofType: "json") {
            let url = URL(fileURLWithPath: bundleResourcePath)
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            content = try JSONDecoder().decode(T.self, from: data)
        }
        else {
            content = nil
        }

        return content
    }

    /// Safely decode a JSON file located in a bundle's resources to a specified `Decodable` struct.
    /// - Parameter resourcePath: The name of the resource to decode.
    ///
    /// If the resource failed to be decoded, `nil` will be returned instead. To forcefully decode and throw an error,
    /// use ``JSONDecoder.decodeFromResource`` instead.
    ///
    /// - SeeAlso: ``JSONDecoder.decodeFromResource``
    static func safeDecodeFromResource<T: Decodable>(from resourcePath: String) -> T? {
        var content: T? = nil
        do {
            content = try decodeFromResource(from: resourcePath)
        } catch {
            print("An error occurred when decoding from JSON: \(error.localizedDescription)")
            content = nil
        }
        return content
    }
}
