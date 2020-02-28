//
//  ManagedInfusionLog+CoreDataClass.swift
//  wcisc
//
//  Created by 李灿晨 on 2/21/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedInfusionLog)
public class ManagedInfusionLog: NSManagedObject {
    
    func initialize(with log: InfusionLog) {
        self.timestamp = log.timestamp
        self.dosage = log.dosage
        self.status = Int32(log.status.rawValue)
    }
    
    func export() -> InfusionLog {
        return InfusionLog(
            timestamp: self.timestamp!,
            dosage: self.dosage,
            status: InfusionStatus(rawValue: Int(self.status))!
        )
    }

}
