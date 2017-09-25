//
//  TrainingDataSource.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 9/19/17.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

class TrainingDataSource {

    var settingsDataSource: SettingsDataSource {
        return SettingsDataSource.shared
    }

    var durationText: String {
        return TrainingDataSource.text(forTimeInSeconds: UInt32(training.duration))
    }

    var maxHeartRate: UInt32 {
        return (heartRates.map { $0.heartRate }).max() ?? 0
    }

    var minHeartRate: UInt32 {
        return (heartRates.map { $0.heartRate }).min() ?? 0
    }

    var avgHeartRate: UInt32 {
        guard !heartRates.isEmpty else { return 0 }
        return (heartRates.map { $0.heartRate }).reduce(0, +) / UInt32(heartRates.count)
    }

    var fatBurnZoneTimeText: String {
        return TrainingDataSource.text(forTimeInSeconds: fatBurnTime)
    }

    var fatBurnZonePercent: Int {
        return training.duration == 0
            ? 0
            : Int(round(Double(fatBurnTime) * 100.0 / Double(training.duration)))
    }

    var heartRates: [HRMeasurement] {
        return storeManager?.measurements(of: training) ?? []
    }

    private var training: Training

    private var storeManager: TrainingsStorageManager? {
        return DataStorageManager.shared.trainingsManager
    }
    
    private var fatBurnTime: UInt32 {
        guard !heartRates.isEmpty else { return 0 }

        var inFatBurn = false
        var result: UInt32 = 0

        let inInterval = { [unowned self] (heartRate: UInt32) -> Bool in
            return self.settingsDataSource.minFatBurnHeartRate <= heartRate &&
                   heartRate <= self.settingsDataSource.maxFatBurnHeartRate
        }

        var t0: UInt32 = 0

        let tSwitch = { [unowned self] (i1: Int, i2: Int) -> UInt32 in
            let h1 = self.heartRates[i1].heartRate
            let h2 = self.heartRates[i2].heartRate
            let t1 = self.heartRates[i1].seconds
            let t2 = self.heartRates[i2].seconds
            let h = h1 > h2
                ? self.settingsDataSource.maxFatBurnHeartRate
                : self.settingsDataSource.minFatBurnHeartRate

            return ((h - h1) * t2 + (h2 - h) * t1) / (h2 - h1)
        }

        for (i, hr) in heartRates.enumerated() {
            if inInterval(hr.heartRate) && !inFatBurn {
                t0 = i > 0 ? tSwitch(i - 1, i) : hr.seconds
                inFatBurn = true
            } else if !inInterval(hr.heartRate) && inFatBurn {
                result += tSwitch(i - 1, i) - t0
            }
        }

        if inFatBurn {
            result += heartRates[heartRates.count - 1].seconds - t0
        }

        return result
    }

    class func text(forTimeInSeconds time: UInt32) -> String {
        var result = ""

        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = (time % 3600) % 60

        if hours > 0 {
            result += "\(hours) h"
        }

        if minutes > 0 || seconds > 0 {
            if !result.isEmpty {
                result += " "
            }
            result += "\(minutes) min"
        }

        if !result.isEmpty {
            result += " "
        }

        result += "\(seconds) s"

        return result
    }

    class func text(forDate date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: date)
    }

    init(training: Training) {
        self.training = training
    }

}
