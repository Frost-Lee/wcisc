//
//  Structures.swift
//  wcisc
//
//  Created by 李灿晨 on 2/19/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import Foundation

enum InfusionStatus: Int {
    case done = 0
    case externalDeviceNotAligned
    case cannotTriggerInjection
    case pumpError
    
    func indicateText() -> String {
        switch self {
        case .done:
            return "Infusion finished"
        case .externalDeviceNotAligned:
            return "External device not aligned"
        case .cannotTriggerInjection:
            return "External device cannot trigger injection"
        case .pumpError:
            return "Pump needs refill"
        }
    }
}

/**
 - TODO:
    new data storage logic is expected for `InfusionSafetyConfiguration`.
 */

struct InfusionSafetyConfiguration {
    var maxDailyDosage: Double
}

struct AutoInfusionConfiguration {
    /// The start time of the auto infusion.
    var startTime: Date
    /// The time interval of the infusion, in minute.
    var timeInterval: TimeInterval
    /// The dosage of the infusion, in number of pushes.
    var dosage: Double
}

struct InfusionLog {
    var timestamp: Date
    var dosage: Double
    var status: InfusionStatus
}
