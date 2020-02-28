//
//  ManagedInfusionLog+CoreDataProperties.swift
//  wcisc
//
//  Created by 李灿晨 on 2/21/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedInfusionLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedInfusionLog> {
        return NSFetchRequest<ManagedInfusionLog>(entityName: "ManagedInfusionLog")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var dosage: Double
    @NSManaged public var status: Int32

}
