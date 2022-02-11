// 
//  Statuses.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 11/2/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import XCTest
@testable import Capstone

/// Test cases for statuses/posts in Codename Shout.
class ShoutTest_Status: XCTestCase {

    /// Test that a HTML-formatted string is stripped and converted to plain text.
    func testStatusConversionToPlainText() throws {
        let originalText = "<p>Hello, world!</p>"
        let expectedText = "Hello, world!"
        XCTAssertEqual(originalText.toPlainText(), expectedText)
    }

    /// Test that an HTML-formatted string is stripped, converted to plain text, and ignores any HTML formatting.
    func testStatusConversionToPlainTextIgnoresFormatting() throws {
        let originalText = """
        <p>
            Shout, shout, let it all out<br/>
            <b>These</b> are the things I can do without<br/>
            Come on; I'm talking to you<br/>
            <span class="roland">Come on</span>
        </p>
        """
        let convertedText = originalText.toPlainText()
        for element in ["<p>", "</p>", "<br/>", "<b>", "</b>", "<span", "</span>"] {
            XCTAssertTrue(!convertedText.contains(element))
        }
    }

}
