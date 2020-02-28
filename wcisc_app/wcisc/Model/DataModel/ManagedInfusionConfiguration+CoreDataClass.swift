//
//  ManagedInfusionConfiguration+CoreDataClass.swift
//  wcisc
//
//  Created by 李灿晨 on 2/21/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedInfusionConfiguration)
public class ManagedInfusionConfiguration: NSManagedObject {
    
    func initialize(with configuration: InfusionConfiguration) {
        self.minInfusionInterval = configuration.minInfusionInterval
        self.maxSingleDosage = configuration.maxSingleDosage
        self.maxDailyDosage = configuration.maxDailyDosage
    }
    
    func export() -> InfusionConfiguration {
        return InfusionConfiguration(
            minInfusionInterval: self.minInfusionInterval,
            maxSingleDosage: self.maxSingleDosage,
            maxDailyDosage: self.maxDailyDosage
        )
    }

}
