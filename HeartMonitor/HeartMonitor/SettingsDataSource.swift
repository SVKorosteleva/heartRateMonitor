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

    private(set) var age: UInt
    private(set) var restHeartRate: UInt
    private(set) var minFatBurnHeartRate: UInt
    private(set) var maxFatBurnHeartRate: UInt

    var maxHeartRate: UInt {
        return 220 - age
    }

    var heartRateReserve: UInt {
        return maxHeartRate - restHeartRate
    }

    init() {
        // TODO: Read from CoreData

        self.age = 20
        self.restHeartRate = 80
        // To avoid class method call
        self.minFatBurnHeartRate = 140
        self.maxFatBurnHeartRate = 170

        recalculateFatBurnRates()
    }

    func update(age: UInt) {
        self.age = age

        recalculateFatBurnRates()
    }

    func update(restHeartRate: UInt) {
        self.restHeartRate = restHeartRate

        recalculateFatBurnRates()
    }

    func maxFatBurnHeartRate(increment: Bool) {
        if increment && maxFatBurnHeartRate < maxHeartRate {
            maxFatBurnHeartRate += 1
        } else if !increment && maxFatBurnHeartRate > minFatBurnHeartRate {
            maxFatBurnHeartRate -= 1
        }

        delegate?.heartRatesUpdated()
    }

    func minFatBurnHeartRate(increment: Bool) {
        if increment && minFatBurnHeartRate < maxFatBurnHeartRate {
            minFatBurnHeartRate += 1
        } else if !increment && minFatBurnHeartRate > restHeartRate {
            minFatBurnHeartRate -= 1
        }

        delegate?.heartRatesUpdated()
    }

    private func fatBurnRates() -> (min: UInt, max: UInt) {
        return (min: UInt(0.5 * Double(heartRateReserve)) + restHeartRate,
                max: UInt(0.75 * Double(heartRateReserve)) + restHeartRate)
    }

    private func recalculateFatBurnRates() {
        let rates = fatBurnRates()
        minFatBurnHeartRate = rates.min
        maxFatBurnHeartRate = rates.max

        delegate?.heartRatesUpdated()
    }

}
