//
//  WCISCController.swift
//  wcisc
//
//  Created by 李灿晨 on 3/3/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import CoreBluetooth

protocol WCISCControllerDelegate {
    func centralStateUnavailable(state: CBManagerState)
    func automaticInfusionFailed(error: Error)
}

enum WCISCControllerState {
    case clear
    case connecting
    case configuring
    case infusing
    case runningAutomaticInfusion
}

class WCISCController: NSObject {
    
    static var shared: WCISCController = WCISCController()
    
    var state: WCISCControllerState = .clear
    var delegate: WCISCControllerDelegate?
    
    var deviceConnected: Bool {
        get {
            return BluetoothManager.shared.deviceConnected
        }
    }
    
    override init() {
        super.init()
        BluetoothManager.shared.delegate = self
    }
    
    func connect(deviceName: String, completion: ((Error?) -> ())?) {
        guard state == .clear else {completion?(WCISCControllerError.controllerBusy);return}
        state = .connecting
        BluetoothManager.shared.connect(deviceName: deviceName) { error in
            self.state = .clear
            completion?(error)
        }
    }
    
    func configure(configuration: AutoInfusionConfiguration, completion: ((Error?) -> ())?) {
        guard state == .clear else {completion?(WCISCControllerError.controllerBusy);return}
        state = .configuring
        let configString = String(
            format: "c:%.2f;%.2f",
            configuration.timeInterval,
            configuration.dosage
        )
        BluetoothManager.shared.writeValue(value: configString) { error in
            self.state = .clear
            completion?(error)
        }
    }
    
    func automaticInfuse(configuration: AutoInfusionConfiguration, completion: ((Error?) -> ())?) {
        guard state == .clear else {completion?(WCISCControllerError.controllerBusy);return}
        state = .runningAutomaticInfusion
        if Date() > configuration.startTime {
            completion?(WCISCControllerError.wrongStartTime)
        }
        let timer = Timer(
            fire: configuration.startTime,
            interval: configuration.timeInterval * 60,
            repeats: true
        ) { timer in
            BluetoothManager.shared.writeValue(value: "b:") { error in
                
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        completion?(nil)
    }
    
    func infuse(dosage: Double, completion: ((Error?) -> ())?) {
        guard state == .clear else {completion?(WCISCControllerError.controllerBusy);return}
        state = .infusing
        let startString = String(format: "b:%.2f", dosage)
        BluetoothManager.shared.writeValue(value: startString) { error in
            self.state = .clear
            completion?(error)
        }
    }
    
    func stopInfusion(completion: ((Error?) -> ())?) {
        BluetoothManager.shared.writeValue(value: "s:") { error in
            if error == nil {
                self.state = .clear
            }
            completion?(error)
        }
    }
    
}

extension WCISCController: BluetoothManagerDelegate {
    func valueUpdated(value: String) {
        if value.first! == "l" {
            let tuple = value.split(separator: ":")[1].split(separator: ";").map({Double($0)!})
            DataManager.shared.saveInfusionLogs(
                logs: [InfusionLog(timestamp: Date(), dosage: tuple[0], status: InfusionStatus(rawValue: Int(tuple[1]))!)]
            ) { error in
                if error != nil {
                    self.delegate?.automaticInfusionFailed(error: error!)
                }
            }
        }
    }
    
    func centralStateUnavailable(state: CBManagerState) {
        delegate?.centralStateUnavailable(state: state)
    }
}
