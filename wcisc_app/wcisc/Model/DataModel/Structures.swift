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
    case disruptedInfusionInterval
    case exceededMaximumSingleDosage
    case exceededMaximumDailyDosage
    case pumpError
    
    func indicateText() -> String {
        switch self {
        case .done:
            return "Infusion finished"
        case .disruptedInfusionInterval:
            return "Disrupted infusion interval"
        case .exceededMaximumSingleDosage:
            return "Maximum single dosage exceeded"
        case .exceededMaximumDailyDosage:
            return "Maximum daily dosage exceeded"
        case .pumpError:
            return "Pump needs refill"
        }
    }
}

struct InfusionConfiguration {
    var minInfusionInterval: Double
    var maxSingleDosage: Double
    var maxDailyDosage: Double
}

struct InfusionLog {
    var timestamp: Date
    var dosage: Double
    var status: InfusionStatus
}
