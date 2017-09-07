//
//  HeartMonitorTests.swift
//  HeartMonitorTests
//
//  Created by Светлана Коростелёва on 30.06.17.
//  Copyright © 2017 home. All rights reserved.
//

import XCTest
@testable import HeartMonitor
import CoreBluetooth

class MockDelegate: HeartRateDelegate {
    var currentBTStatus: BTStatus?
    var currentBatteryLevel: UInt8?
    var currentDeviceInfo: String?
    var currentHeartRate: UInt16?

    func updated(deviceInfo: String) {
        currentDeviceInfo = deviceInfo
    }


    func updated(heartRate: UInt16) {
        currentHeartRate = heartRate
    }


    func updated(btStatus: BTStatus) {
        currentBTStatus = btStatus
    }


    func updated(batteryLevel: UInt8) {
        currentBatteryLevel = batteryLevel
    }
}

class MockPeripheral: CBPeripheral {
    var servisesToDiscover = [CBService]()
    var characteristicToNotify: CBCharacteristic?
    var characteristicToRead: CBCharacteristic?

    override func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        servisesToDiscover.append(service)
    }

    override func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        characteristicToNotify = characteristic
    }

    override func readValue(for characteristic: CBCharacteristic) {
        characteristicToRead = characteristic
    }
}

class HeartRateDataSourceTests: XCTestCase {

    var dataSourceUnderTest: HeartRateDataSource!

    
    override func setUp() {
        super.setUp()
        dataSourceUnderTest = HeartRateDataSource()
    }
    
    override func tearDown() {
        dataSourceUnderTest = nil
        super.tearDown()
    }

    func testLoadBluetoothChangesBTStatusSearching() {
        let mockDelegate = MockDelegate()
        dataSourceUnderTest.delegate = mockDelegate

        dataSourceUnderTest.loadBluetooth()

        XCTAssertEqual(mockDelegate.currentBTStatus, BTStatus.searching, "BT status is not updated to Searching")
    }
}
