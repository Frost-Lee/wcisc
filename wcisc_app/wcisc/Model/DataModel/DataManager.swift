//
//  DataManager.swift
//  wcisc
//
//  Created by 李灿晨 on 2/21/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    /// The shared instance of object `DataManager`.
    static var shared: DataManager = DataManager()
    
    /// Context for CoreData.
    private var context: NSManagedObjectContext = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return context
    }()
    
    // MARK: `InfusionConfiguration` operations.
    
    /**
     Update an `InfusionConfiguration` object. Currently, at most 1 `InfusionConfiguration` is
        stored. During the update, if there is any existing `InfusionConfiguration` object, they will be
        removed.
     
     - parameters:
        - configuration: The `InfusionConfiguration` object to be updated.
        - completion: The completion handler. `Error` will be `nil` if the operation is done successfully.
     */
    func updateInfusionConfiguration(configuration: AutoInfusionConfiguration, completion: ((Error?) -> ())?) {
        UserDefaults.standard.set(configuration.startTime, forKey: "AutoInfusionConfiguration_startTime")
        UserDefaults.standard.set(configuration.timeInterval, forKey: "AutoInfusionConfiguration_timeInterval")
        UserDefaults.standard.set(configuration.dosage, forKey: "AutoInfusionConfiguration_dosage")
        completion?(nil)
    }
    
    /**
     Get the `EstimateCapture` object saved by CoreData. Currently at most 1 `InfusionConfiguration`
        is stored, thus the completion handler will return 0 or 1 object.
     
     - Parameters:
        - completion: The completion handler. `Error` will be `nil` if the operation is done successfully.
     */
    func getInfusionConfiguration(completion: (((AutoInfusionConfiguration?, Error?) -> ()))?) {
        let configuration = AutoInfusionConfiguration(
            startTime: UserDefaults.standard.object(forKey: "AutoInfusionConfiguration_startTime") as! Date,
            timeInterval: UserDefaults.standard.double(forKey: "AutoInfusionConfiguration_timeInterval"),
            dosage: UserDefaults.standard.double(forKey: "AutoInfusionConfiguration_dosage")
        )
        completion?(configuration, nil)
    }
    
    // MARK: `InfusionSafetyConfiguration` operations.
    
    func updateInfusionSafetyConfiguration(configuration: InfusionSafetyConfiguration, completion: ((Error?) -> ())?) {
        UserDefaults.standard.set(configuration.maxDailyDosage, forKey: "InfusionSafetyConfiguration_maxDailyDosage")
        completion?(nil)
    }
    
    func getInfusionSafetyConfiguration(completion: (((InfusionSafetyConfiguration?, Error?) -> ()))?) {
        let configuration = InfusionSafetyConfiguration(
            maxDailyDosage: UserDefaults.standard.double(forKey: "InfusionSafetyConfiguration_maxDailyDosage")
        )
        completion?(configuration, nil)
    }
    
    // MARK: `InfusionLog` operations.
    
    /**
     Save the provided infusion logs.
     
     - parameters:
        - logs: The logs to be saved.
        - completion: The completion handler. `Error` will be `nil` if the operation is done successfully.
     */
    func saveInfusionLogs(logs: [InfusionLog], completion: ((Error?) -> ())?) {
        for log in logs {
            let entity = NSEntityDescription.entity(forEntityName: "ManagedInfusionLog", in: context)
            let newLog = ManagedInfusionLog(entity: entity!, insertInto: context)
            newLog.initialize(with: log)
            do {
                try context.save()
            } catch {
                completion?(DataStorageError.saveFailure)
            }
        }
        completion?(nil)
    }
    
    /**
     Fetch all saved `InfusionLog` objects.
     
     - parameters:
        - completion: The completion handler. `Error` will be `nil` if the operation is done successfully.
     */
    func getAllInfusionLogs(completion: (([InfusionLog]?, Error?) -> ())?) {
        let fetchRequest: NSFetchRequest = ManagedInfusionLog.fetchRequest()
        do {
            let managedLogs = (try context.fetch(fetchRequest)) as [ManagedInfusionLog]
            completion?(managedLogs.map({$0.export()}).sorted(by: {$0.timestamp > $1.timestamp}), nil)
        } catch {
            completion?(nil, DataStorageError.fetchFailure)
        }
    }
    
}
