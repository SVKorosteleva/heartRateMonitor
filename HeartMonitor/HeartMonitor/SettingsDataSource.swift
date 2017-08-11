//
//  SettingsDataSource.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 8/7/17.
//  Copyright © 2017 home. All rights reserved.
//

protocol SettingsDataDelegate {
    func heartRatesUpdated()
}

class SettingsDataSource {

    var delegate: SettingsDataDelegate?

    private(set) var age: UInt32
    private(set) var restHeartRate: UInt32
    private(set) var minFatBurnHeartRate: UInt32
    private(set) var maxFatBurnHeartRate: UInt32

    private var storeManager: SettingsStorageManager? {
        return DataStorageManager.shared.settingsManager
    }

    var maxHeartRate: UInt32 {
        return 220 - age
    }

    var heartRateReserve: UInt32 {
        return maxHeartRate - restHeartRate
    }

    init() {
        // Init with default values

        self.age = 20
        self.restHeartRate = 80
        // To avoid class method call
        self.minFatBurnHeartRate = 140
        self.maxFatBurnHeartRate = 170

        recalculateFatBurnRates(save: false)

        // Read actual values from data storage
        let settings = storeManager?.settings()

        self.age = settings?[SettingsKey.age] ?? self.age
        self.restHeartRate = settings?[SettingsKey.restingHeartRate] ?? self.restHeartRate
        self.minFatBurnHeartRate =
            settings?[SettingsKey.fatBurnMinHeartRate] ?? self.minFatBurnHeartRate
        self.maxFatBurnHeartRate =
            settings?[SettingsKey.fatBurnMaxHeartRate] ?? self.maxFatBurnHeartRate
    }

    func update(age: UInt32) {
        self.age = age

        storeManager?.save(SettingsValue(age), forSetting: .age)
        recalculateFatBurnRates(save: true)
    }

    func update(restHeartRate: UInt32) {
        self.restHeartRate = restHeartRate

        storeManager?.save(SettingsValue(restHeartRate), forSetting: .restingHeartRate)
        recalculateFatBurnRates(save: true)
    }

    func maxFatBurnHeartRate(increment: Bool) {
        if increment && maxFatBurnHeartRate < maxHeartRate {
            maxFatBurnHeartRate += 1
        } else if !increment && maxFatBurnHeartRate > minFatBurnHeartRate {
            maxFatBurnHeartRate -= 1
        }

        storeManager?.save(maxFatBurnHeartRate, forSetting: .fatBurnMaxHeartRate)
        delegate?.heartRatesUpdated()
    }

    func minFatBurnHeartRate(increment: Bool) {
        if increment && minFatBurnHeartRate < maxFatBurnHeartRate {
            minFatBurnHeartRate += 1
        } else if !increment && minFatBurnHeartRate > restHeartRate {
            minFatBurnHeartRate -= 1
        }

        storeManager?.save(minFatBurnHeartRate, forSetting: .fatBurnMinHeartRate)
        delegate?.heartRatesUpdated()
    }

    private func fatBurnRates() -> (min: UInt32, max: UInt32) {
        return (min: UInt32(0.5 * Double(heartRateReserve)) + restHeartRate,
                max: UInt32(0.75 * Double(heartRateReserve)) + restHeartRate)
    }

    private func recalculateFatBurnRates(save: Bool) {
        let rates = fatBurnRates()
        minFatBurnHeartRate = rates.min
        maxFatBurnHeartRate = rates.max

        if save {
            storeManager?.save(minFatBurnHeartRate, forSetting: .fatBurnMinHeartRate)
            storeManager?.save(maxFatBurnHeartRate, forSetting: .fatBurnMaxHeartRate)
        }

        delegate?.heartRatesUpdated()
    }

}
