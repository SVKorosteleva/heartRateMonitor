//
//  HeartRateDataSource.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 7/6/17.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import QuartzCore
import CoreBluetooth

/// Possible states of BT connection to heart rate monitor
enum BTStatus {
    /// BT is turned off on the device
    case off
    /// Looking for BT heart rate monitor
    case searching
    /// Some other device is picked up, recommended to turn BT off and on again
    case switchBT
    /// BT heart rate monitor is connected, receiving data from it
    case ready
}

/// To report BT status and data
protocol HeartRateDelegate {
    /**
     Reports info about BT heart rate monitor
     - Parameter deviceInfo: 
        Text info about the device - position, manufacturer, connection state
    */
    func updated(deviceInfo: String)

    /**
     Reports heart rate received from BT heart rate monitor
     - Parameter heartRate:
        Current heart rate in bpm (beats per minute)
     */
    func updated(heartRate: UInt16)

    /**
     Reports current status of connection with BT heart rate monitor
     - Parameter btStatus:
        Current status of connection with BT heart rate monitor
     */
    func updated(btStatus: BTStatus)

    /**
     Reports battery level received from BT heart rate monitor
     - Parameter batteryLevel:
        Current battery level received from BT heart rate monitor
     */
    func updated(batteryLevel: UInt8)

}

class HeartRateDataSource: NSObject {

    fileprivate(set) var connectedInfo = ""
    fileprivate(set) var bodyData = ""
    fileprivate(set) var manufacturer = ""
    fileprivate(set) var deviceData = ""
    fileprivate(set) var heartRate: UInt16 = 0
    fileprivate(set) var batteryLevel: UInt8 = 0

    fileprivate let deviceInfoServiceUUID = "180A"
    fileprivate let heartRateServiceUUID = "180D"
    fileprivate let batteryServiceUUID = "180F"

    fileprivate let measurementCharacteristicUUID = "2A37"
    fileprivate let bodyLocationCharacteristicUUID = "2A38"
    fileprivate let manufacturerNameCharacteristicUUID = "2A29"
    fileprivate let batteryLeveleCharacteristicUUID = "2A19"

    fileprivate var centralManager: CBCentralManager?
    fileprivate var hrmPeripheral: CBPeripheral?

    var delegate: HeartRateDelegate?

    func loadBluetooth() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        delegate?.updated(btStatus: .searching)
    }

    func stopBluetooth() {
        centralManager?.stopScan()
        delegate?.updated(heartRate: 0)
        delegate?.updated(deviceInfo: "Connected: NO")
        delegate?.updated(batteryLevel: 100)
        delegate?.updated(btStatus: .off)
        centralManager = nil
    }

    //MARK: CBCharacteristic Helpers

    fileprivate func getHeartBPMData(from characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Heart rate data error: \(String(describing: error))")
            return
        }
        guard let data = characteristic.value else {
            print("Invalid heart rate data")
            return
        }

        let reportData = [UInt8](data)
        if reportData[0] & 0x01 != 0 {
            heartRate = UInt16(reportData[0])
        } else {
            heartRate = CFSwapInt16LittleToHost(UInt16(reportData[1]))
        }

        delegate?.updated(heartRate: heartRate)

    }

    fileprivate func getManufacturerName(from characteristic: CBCharacteristic) {
        guard let data = characteristic.value,
            let manufacturerName = String(data: data, encoding: .utf8) else { return }

        manufacturer = "Manufacturer: \(manufacturerName)"
    }

    fileprivate func getBodyLocation(from characteristic: CBCharacteristic) {
        guard let data = characteristic.value else { return }
        let bodyDataArray = [UInt8](data)
        let bodyLocation = bodyDataArray[0]

        bodyData = "Body location: \(bodyLocation == 1 ? "Chest" : "Undefined")"
    }

    fileprivate func getBatteryLevel(from characteristic: CBCharacteristic) {
        guard let data = characteristic.value else { return }
        let batteryLevelArray = [UInt8](data)
        batteryLevel = batteryLevelArray[0]

        delegate?.updated(batteryLevel: batteryLevel)
    }

    // MARK: Helpers

    fileprivate func startBTScan() {
        let services = [CBUUID(string: heartRateServiceUUID),
                        CBUUID(string: deviceInfoServiceUUID),
                        CBUUID(string: batteryServiceUUID)]
        centralManager?.scanForPeripherals(withServices: services, options: nil)
    }

}

extension HeartRateDataSource: CBCentralManagerDelegate {

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        connectedInfo = "Connected: " + (peripheral.state == .connected ? "YES" : "NO")
        print(connectedInfo)

    }

    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        connectedInfo = "Connected: " + (peripheral.state == .connected ? "YES" : "NO")
        print(connectedInfo)
        print(error.debugDescription)
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {

        guard let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID],
            serviceUUIDs.contains(CBUUID(string: heartRateServiceUUID)) else
        {
            print("Heart rate monitor not found, continue scanning")
            delegate?.updated(btStatus: .switchBT)
            return
        }

        guard let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
            let centralManager = centralManager,
            !localName.isEmpty else {
                print("Local name not found")
                return
        }

        delegate?.updated(btStatus: .ready)

        print("Found heart rate monitor: \(localName), signal strength \(RSSI)")
        centralManager.stopScan()
        hrmPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("BT hardware is powered off")
            delegate?.updated(btStatus: .off)
            delegate?.updated(deviceInfo: "")
            delegate?.updated(heartRate: 0)

        case .poweredOn:
            print("BT hardware is powered on and ready")
            delegate?.updated(btStatus: .searching)
            // BT power on - start scan
            startBTScan()

        case .unauthorized:
            print("BT hardware is unautorized")
        case .unknown:
            print("BT hardware is unknown")
        case .unsupported:
            print("BT hardware is not supported on this platform")
        case .resetting:
            print("BT hardware is resetting")
        }
    }

}

extension HeartRateDataSource: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("Services not discovered")
            return
        }
        for service in services {
            print("Discovered service: \(service.uuid.uuidString)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {

        switch service.uuid {
        case CBUUID(string: heartRateServiceUUID):
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics {
                switch characteristic.uuid {
                case CBUUID(string: measurementCharacteristicUUID):
                    hrmPeripheral?.setNotifyValue(true, for: characteristic)
                    print("Found heart rate measurement characteristic")
                case CBUUID(string: bodyLocationCharacteristicUUID):
                    hrmPeripheral?.readValue(for: characteristic)
                    print("Found body sensor location characteristic")
                default:
                    print("Characteristic \(characteristic) of service \(service) is not handled")
                }
            }

        case CBUUID(string: deviceInfoServiceUUID):
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: manufacturerNameCharacteristicUUID) {
                    hrmPeripheral?.readValue(for: characteristic)
                    print("Found a device manufacturer name characteristic")
                } else {
                    print("Characteristic \(characteristic) of service \(service) is not handled")
                }
            }

        case CBUUID(string: batteryServiceUUID):
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: batteryLeveleCharacteristicUUID) {
                    hrmPeripheral?.readValue(for: characteristic)
                    print("Found a battery level characteristic")
                } else {
                    print("Characteristic \(characteristic) of service \(service) is not handled")
                }
            }

        default:
            print("Service \(service) is not handled")
        }

    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
        case CBUUID(string:measurementCharacteristicUUID):
            getHeartBPMData(from: characteristic, error: error)
        case CBUUID(string: manufacturerNameCharacteristicUUID):
            getManufacturerName(from: characteristic)
        case CBUUID(string: bodyLocationCharacteristicUUID):
            getBodyLocation(from: characteristic)
        case CBUUID(string: batteryLeveleCharacteristicUUID):
            getBatteryLevel(from: characteristic)
        default:
            print("Characteristic is not handled: \(characteristic)")
        }

        delegate?.updated(deviceInfo: "\(connectedInfo)\n\(bodyData)\n\(manufacturer)")
    }

}


