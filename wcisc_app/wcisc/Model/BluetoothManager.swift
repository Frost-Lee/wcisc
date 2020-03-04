//
//  BluetoothManager.swift
//  wcisc
//
//  Created by 李灿晨 on 2/28/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import CoreBluetooth

protocol BluetoothManagerDelegate {
    /**
     Notify the delegate that the `BluetoothManager` was notified that the central device is in unavailable
        state. This method will be called if the `BluetoothManager` is not performing any task, otherwise,
        the error message will be notified via completion handler.
    
     - parameters:
        - state: The current state of the central device.
     */
    func centralStateUnavailable(state: CBManagerState)
    func valueUpdated(value: String)
}

enum BluetoothManagerState {
    case clear
    case waitingConnection
    case waitingWrite
}

class BluetoothManager: NSObject {
    
    static var shared: BluetoothManager = BluetoothManager()
    
    var delegate: BluetoothManagerDelegate?
    
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    
    private var state: BluetoothManagerState = .clear
    private var pendingCompletion: ((Error?) -> ())?
    private var pendingMethodParameter: Any?
    
    /// TX is used for writing with response.
    private var txCharacter: CBCharacteristic?
    /// RX is used for notifying.
    private var rxCharacter: CBCharacteristic?
    var deviceConnected: Bool {
        get {
            return rxCharacter != nil && txCharacter != nil
        }
    }
    
    private let txUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    private let rxUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    private let scanningOptions = [
        CBCentralManagerScanOptionAllowDuplicatesKey : false,
        CBCentralManagerOptionShowPowerAlertKey : true
    ]
    private let timeout: Double = 10.0
    
    /**
     The method will reset all properties of `BluetoothManager`, resign all delegates, and reset the pending
        jobs.
     */
    func reset() {
        centralManager?.delegate = nil
        peripheral?.delegate = nil
        centralManager = nil
        peripheral = nil
        txCharacter = nil
        rxCharacter = nil
        resetPendingJob(successful: false)
    }
    
    /**
     Connect to the device.
     
     The following operations are performed sequentially: setup `CBCentralManager`, scan for peripheral,
        connect to peripheral, discover service, discover characteristics, find RX and TX characteristics, done.
     
     - parameters:
        - deviceName: The name of the device to be connected.
        - completion: The completion handler. `Error` will be `nil` if the operation is done successfully.
     */
    func connect(deviceName: String, completion: ((Error?) -> ())?) {
        guard state == .clear else {completion?(BluetoothError.managerBusy);return}
        if deviceConnected {completion?(nil);return}
        setPendingJob(state: .waitingConnection, completion: completion, parameter: deviceName)
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        } else {
            centralManager?.scanForPeripherals(withServices: nil, options: scanningOptions)
        }
        startTimeoutTimer()
    }
    
    func writeValue(value: String, completion: ((Error?) -> ())?) {
        guard state == .clear else {completion?(BluetoothError.managerBusy);return}
        guard deviceConnected else {completion?(BluetoothError.deviceNotConnected);return}
        setPendingJob(state: .waitingWrite, completion: completion, parameter: value)
        // The maximum buffer size of the external device is 20, see https://learn.adafruit.com/introducing-the-adafruit-bluefruit-le-uart-friend/ble-gatt
        peripheral?.writeValue(value.data(using: .ascii)!, for: txCharacter!, type: .withResponse)
        startTimeoutTimer()
    }
    
    /**
     Reset the pending job of the `BluetoothManager`. The completion handler will be called and then set
        to `nil`.
     */
    private func resetPendingJob(successful: Bool) {
        pendingMethodParameter = nil
        state = .clear
        let copiedCompletion = pendingCompletion
        pendingCompletion = nil
        if successful {
            copiedCompletion?(nil)
        } else {
            copiedCompletion?(BluetoothError.operationFailure)
        }
    }
    
    private func setPendingJob(
        state: BluetoothManagerState,
        completion: ((Error?) -> ())?,
        parameter: Any?
    ) {
        self.state = state
        pendingCompletion = completion
        pendingMethodParameter = parameter
    }
    
    /**
     Start a timer for `timeout` seconds. If the timer ends but there is still a pending job, the job will be declared
        failure, and then be cleared.
     */
    private func startTimeoutTimer() {
        Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { timer in
            if self.state != .clear {
                print("Expired")
                self.resetPendingJob(successful: false)
            }
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            if state == .waitingConnection {
                centralManager?.scanForPeripherals(withServices: nil, options: scanningOptions)
            }
        default:
            if state == .clear {
                delegate?.centralStateUnavailable(state: central.state)
            } else {
                resetPendingJob(successful: false)
            }
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any], rssi RSSI: NSNumber
    ) {
        print(peripheral.name ?? "unnamed peripheral")
        if state == .waitingConnection && peripheral.name == pendingMethodParameter as? String {
            print("start connecting")
            self.peripheral = peripheral
            peripheral.delegate = self
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        print("connected called")
        if state == .waitingConnection {
            print("connected")
            central.stopScan()
            peripheral.discoverServices(nil)
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        if state == .waitingConnection {
            central.stopScan()
            print("fail to connect")
            resetPendingJob(successful: false)
        }
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if state == .waitingConnection {
            guard let services = peripheral.services else {return}
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if state == .waitingConnection {
            guard let characteristics = service.characteristics else {return}
            for character in characteristics {
                if character.uuid == txUUID {
                    txCharacter = character
                } else if character.uuid == rxUUID {
                    rxCharacter = character
                    peripheral.setNotifyValue(true, for: rxCharacter!)
                }
            }
            if deviceConnected {
                resetPendingJob(successful: true)
            }
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if state == .waitingWrite {
            resetPendingJob(successful: error == nil)
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        delegate?.valueUpdated(value: String(data: characteristic.value!, encoding: .ascii)!)
    }
}
