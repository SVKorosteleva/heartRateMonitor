//
//  SettingsStorageManager.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 8/10/17.
//  Copyright © 2017 home. All rights reserved.
//

import CoreData

enum SettingsKey: String {
    case age
    case restingHeartRate
    case fatBurnMinHeartRate
    case fatBurnMaxHeartRate
}

typealias SettingsValue = UInt32

class SettingsStorageManager {
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func settings() -> [SettingsKey: SettingsValue] {
        let fetchRequest = NSFetchRequest<Settings>(entityName: "Settings")
        guard let settings = try? context.fetch(fetchRequest) else {
            return [:]
        }

        var result = [SettingsKey: SettingsValue]()
        for setting in settings {
            if let settingKey = setting.settingKey,
               let key = SettingsKey(rawValue: settingKey) {
                result[key] = SettingsValue(setting.settingValue)
            }
        }

        return result
    }

    func save(_ value: SettingsValue, forSetting key: SettingsKey) {
        let fetchRequest = NSFetchRequest<Settings>(entityName: "Settings")
        fetchRequest.predicate = NSPredicate(format: "settingKey == %@", key.rawValue)
        guard let settings = try? context.fetch(fetchRequest) else {
            return
        }

        if let setting = settings.first {
            setting.settingValue = Int32(value)
        } else {
            guard let setting =
                NSEntityDescription.insertNewObject(forEntityName: "Settings",
                                                    into: context) as? Settings else {
                return
            }
            setting.settingKey = key.rawValue
            setting.settingValue = Int32(value)
        }

        do {
            try context.save()
        } catch let e {
            print("Unable to save setting: \(e.localizedDescription)")
        }
    }

}
