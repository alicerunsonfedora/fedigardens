//
//  GardenSettingPropertyWrapperTests.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 15/7/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import XCTest
@testable import GardenSettings

class GardenSettingPropertyWrapperTests: XCTestCase {
    static let testStore = UserDefaults(suiteName: "app.fedigardens.mail.test-suite")!

    override func tearDown() {
        let keys = GardenSettingPropertyWrapperTests.testStore.dictionaryRepresentation().keys
        for key in keys {
            GardenSettingPropertyWrapperTests.testStore.removeObject(forKey: key)
        }
        GardenSettingPropertyWrapperTests.testStore.synchronize()
    }

    func testPropertyWrapperRetrievesDefaultValueWithMinimumApplied() throws {
        struct MinimumSettingConstants {
            @GardenSetting(key: .loadLimit, store: GardenSettingPropertyWrapperTests.testStore, minimum: 5)
            var loadLimit = 3
        }

        let testManager = MinimumSettingConstants()
        XCTAssertEqual(testManager.loadLimit, 5)
    }

    func testPropertyWrapperRetrievesDefaultValues() throws {
        struct DefaultValueSettingConstants {
            @GardenSetting(key: .loadLimit, store: GardenSettingPropertyWrapperTests.testStore, minimum: 5)
            var loadLimit = 10

            @GardenSetting(key: .frugalMode, store: GardenSettingPropertyWrapperTests.testStore)
            var frugalModeEnabled = false
        }

        let testManager = DefaultValueSettingConstants()
        XCTAssertEqual(testManager.loadLimit, 10)
        XCTAssertEqual(testManager.frugalModeEnabled, false)
    }

    // TODO: Revisit this to test bad data values.
    func testPropertyWrapperRetrievesDecodedVisibility() throws {
        struct VisibilitySettingConstants {
            @GardenSetting(key: .defaultVisibility, defaultVisibility: .private)
            var defaultPostVisibility = .public

            @GardenSetting(key: .defaultQuoteVisibility, defaultVisibility: .unlisted)
            var defaultQuoteVisibility = .public
        }

        let testManager = VisibilitySettingConstants()
        XCTAssertEqual(testManager.defaultPostVisibility, .public)
        XCTAssertEqual(testManager.defaultQuoteVisibility, .public)
//        GardenSettingPropertyWrapperTests.testStore.setValue("break me",
//                                                             forKey: .defaultQuoteVisibility)
//        XCTAssertEqual(testManager.defaultQuoteVisibility, .unlisted)
    }

    func testPropertyWrapperStoresExpectedValues() throws {
        struct UserSettings {
            @GardenSetting(key: .loadLimit, store: GardenSettingPropertyWrapperTests.testStore, minimum: 5)
            var loadLimit = 10

            @GardenSetting(key: .frugalMode, store: GardenSettingPropertyWrapperTests.testStore)
            var frugalModeEnabled = false
        }
        var testManager = UserSettings()
        testManager.frugalModeEnabled = true
        testManager.loadLimit = 20

        XCTAssertEqual(testManager.frugalModeEnabled, true)
        XCTAssertEqual(
            GardenSettingPropertyWrapperTests.testStore.bool(forKey: GardenSettingsKey.frugalMode.rawValue),
            true)
        XCTAssertEqual(testManager.loadLimit, 20)
        XCTAssertEqual(
            GardenSettingPropertyWrapperTests.testStore.integer(forKey: GardenSettingsKey.loadLimit.rawValue),
            20)

    }
}
