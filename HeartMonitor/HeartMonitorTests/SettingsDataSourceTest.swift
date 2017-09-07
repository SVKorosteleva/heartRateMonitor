//
//  SettingsDataSourceTest.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 9/7/17.
//  Copyright © 2017 home. All rights reserved.
//

import XCTest
@testable import HeartMonitor

class MockSettingsDelegate: SettingsDataDelegate {
    var updateCalled = false
    func heartRatesUpdated() {
        updateCalled = true
    }
}

class SettingsDataSourceTest: XCTestCase {
    var dataSourceToTest: SettingsDataSource!
    
    override func setUp() {
        super.setUp()
        dataSourceToTest = SettingsDataSource.shared
    }
    
    override func tearDown() {
        dataSourceToTest = nil
        super.tearDown()
    }

    func testUpdateAge() {
        let age: UInt32 = 33
        let mockDelegate = MockSettingsDelegate()
        dataSourceToTest.delegate = mockDelegate

        dataSourceToTest.update(age: age)

        XCTAssertEqual(dataSourceToTest.age, age, "Age was not updated correctly")
        XCTAssertEqual(dataSourceToTest.maxHeartRate, 220 - age, "Max heart rate was not updated correctly")
        XCTAssert(mockDelegate.updateCalled, "Delegate call was not performed")
    }

    func testUpdateRestHeartRate() {
        let restHeartRate: UInt32 = 85
        let mockDelegate = MockSettingsDelegate()
        dataSourceToTest.delegate = mockDelegate

        dataSourceToTest.update(restHeartRate: restHeartRate)

        XCTAssertEqual(dataSourceToTest.restHeartRate, restHeartRate, "Rest heart rate was not updated correctly")
        XCTAssert(mockDelegate.updateCalled, "Delegate call was not performed")

    }

    func testMaxFatBurnHeartRateIncrement() {
        let increment = true
        let mockDelegate = MockSettingsDelegate()
        dataSourceToTest.delegate = mockDelegate
        let oldMaxFatBurnHeartRate = dataSourceToTest.maxFatBurnHeartRate

        dataSourceToTest.maxFatBurnHeartRate(increment: increment)

        XCTAssertEqual(dataSourceToTest.maxFatBurnHeartRate, oldMaxFatBurnHeartRate + UInt32(1), "Max fat burn heart rate was not incremented")
        XCTAssert(mockDelegate.updateCalled, "Delegate call was not performed")
    }

    func testMaxFatBurnHeartRateDecrement() {
        let increment = false
        let mockDelegate = MockSettingsDelegate()
        dataSourceToTest.delegate = mockDelegate
        let oldMaxFatBurnHeartRate = dataSourceToTest.maxFatBurnHeartRate

        dataSourceToTest.maxFatBurnHeartRate(increment: increment)

        XCTAssertEqual(dataSourceToTest.maxFatBurnHeartRate, oldMaxFatBurnHeartRate - UInt32(1), "Max fat burn heart rate was not decremented")
        XCTAssert(mockDelegate.updateCalled, "Delegate call was not performed")
    }

    func testMinFatBurnHeartRateIncrement() {
        let increment = true
        let mockDelegate = MockSettingsDelegate()
        dataSourceToTest.delegate = mockDelegate
        let oldMinFatBurnHeartRate = dataSourceToTest.minFatBurnHeartRate

        dataSourceToTest.minFatBurnHeartRate(increment: increment)

        XCTAssertEqual(dataSourceToTest.minFatBurnHeartRate, oldMinFatBurnHeartRate + UInt32(1), "Min fat burn heart rate was not incremented")
        XCTAssert(mockDelegate.updateCalled, "Delegate call was not performed")
    }

    func testMinFatBurnHeartRateDecrement() {
        let increment = false
        let mockDelegate = MockSettingsDelegate()
        dataSourceToTest.delegate = mockDelegate
        let oldMinFatBurnHeartRate = dataSourceToTest.minFatBurnHeartRate

        dataSourceToTest.minFatBurnHeartRate(increment: increment)

        XCTAssertEqual(dataSourceToTest.minFatBurnHeartRate, oldMinFatBurnHeartRate - UInt32(1), "Min fat burn heart rate was not decremented")
        XCTAssert(mockDelegate.updateCalled, "Delegate call was not performed")
    }
    
}
