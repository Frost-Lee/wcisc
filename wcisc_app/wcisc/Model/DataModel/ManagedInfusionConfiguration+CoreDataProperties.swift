//
//  ManagedInfusionConfiguration+CoreDataProperties.swift
//  wcisc
//
//  Created by 李灿晨 on 2/21/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedInfusionConfiguration {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedInfusionConfiguration> {
        return NSFetchRequest<ManagedInfusionConfiguration>(entityName: "ManagedInfusionConfiguration")
    }

    @NSManaged public var minInfusionInterval: Double
    @NSManaged public var maxSingleDosage: Double
    @NSManaged public var maxDailyDosage: Double

}
