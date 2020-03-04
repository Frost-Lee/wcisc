//
//  Errors.swift
//  wcisc
//
//  Created by 李灿晨 on 2/21/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import Foundation

enum DataStorageError: Error {
    case saveFailure
    case fetchFailure
}

enum BluetoothError: Error {
    case managerBusy
    case operationFailure
    case deviceNotConnected
}

enum WCISCControllerError: Error {
    case controllerBusy
    case wrongStartTime
}
