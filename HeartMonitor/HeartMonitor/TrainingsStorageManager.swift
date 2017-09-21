//
//  TrainingsStorageManager.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 9/19/17.
//  Copyright © 2017 home. All rights reserved.
//

import CoreData

struct HRMeasurement {
    let heartRate: UInt32
    let seconds: UInt32
}

class TrainingsStorageManager {
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func createTraining() -> Training? {
        guard let training
            = NSEntityDescription
                .insertNewObject(forEntityName: "Training",
                                 into: context) as? Training else { return nil }
        training.dateTimeStart = Date() as NSDate
        training.duration = 0

        do {
            try context.save()
        } catch let e {
            print("Unable to create training: \(e.localizedDescription)")
            return nil
        }

        return training
    }

    func addMeasurement(_ heartRate: UInt32, duration: UInt32, to training: Training) {
        guard let measurement =
            NSEntityDescription
                .insertNewObject(forEntityName: "HeartRateMeasurement",
                                 into: context) as? HeartRateMeasurement  else { return }
        measurement.heartRate = Int32(heartRate)
        measurement.secondsFromBeginning = Int32(duration)

        training.measurements = training.measurements?.adding(measurement) as NSSet?
        training.duration = Int32(duration)

        do {
            try context.save()
        } catch let e {
            print("Unable to add data to training: \(e.localizedDescription)")
        }
    }

    func trainings() -> [Training] {
        let fetchRequest = NSFetchRequest<Training>(entityName: "Trainings")
        guard let trainings = try? context.fetch(fetchRequest) else {
            return []
        }

        return trainings.sorted(by: {
            ($0.dateTimeStart as Date?) ?? Date() > ($1.dateTimeStart as Date?) ?? Date()
        })
    }

    func measurements(of training: Training) -> [HRMeasurement] {
        guard let trainingMeasurements
            = training.measurements as? Set<HeartRateMeasurement> else {
            return []
        }

        return trainingMeasurements.map {
            HRMeasurement(heartRate: UInt32($0.heartRate),
                        seconds: UInt32($0.secondsFromBeginning))
            }.sorted(by: { $0.seconds < $1.seconds })
    }

}
