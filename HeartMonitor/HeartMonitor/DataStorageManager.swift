//
//  DataStorageManager.swift
//  HeartMonitor
//
//  Created by Светлана Коростелёва on 8/10/17.
//  Copyright © 2017 home. All rights reserved.
//

import CoreData

class DataStorageManager {
    static var shared = DataStorageManager()

    private(set) var settingsManager: SettingsStorageManager?

    private lazy var model: NSManagedObjectModel? = self.dataModel()
    private lazy var storeCoordinator: NSPersistentStoreCoordinator? =
        self.persistentStoreCoordinator()
    private var context: NSManagedObjectContext?

    private var documentsPath: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }

    private init() {
        self.context = managedObjectContext()

        if let context = self.context {
            self.settingsManager = SettingsStorageManager(context: context)
        }
    }

    private func dataModel() -> NSManagedObjectModel? {
        guard let url =
            Bundle.main.url(forResource: "HeartRateDataModel", withExtension: "momd") else {
            return nil
        }
        return NSManagedObjectModel(contentsOf: url)
    }

    private func persistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        guard let model = model else {
                return nil
        }
        let storeUrl = documentsPath?.appendingPathComponent("DataStorage.sqlite")
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        guard let _ = try? storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                               configurationName: nil,
                                                               at: storeUrl,
                                                               options: nil) else {
            return nil
        }
        return storeCoordinator
    }

    private func managedObjectContext() -> NSManagedObjectContext? {
        guard let storeCoordinator = storeCoordinator else { return nil }
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = storeCoordinator
        return context
    }

}
