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
    func automaticInfusionFailed(status: InfusionStatus)
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
    
    private var dataManager = DataManager.shared
    
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
    
    func isSafe(
        autoInfusionConfiguration: AutoInfusionConfiguration,
        safetyConfiguration: InfusionSafetyConfiguration,
        completion: ((Bool) -> ())?
    ) {
        let maxDailyDosage = safetyConfiguration.maxDailyDosage
        if autoInfusionConfiguration.dosage * (60 * 24 / autoInfusionConfiguration.timeInterval) > maxDailyDosage {
            completion?(false)
            return
        }
        dataManager.getAllInfusionLogs() { logs, error in
            guard error == nil else {completion?(false);return}
            let recentLogs = logs?.filter({autoInfusionConfiguration.startTime.timeIntervalSince($0.timestamp) < 3600 * 24}).sorted(by: {$0.timestamp < $1.timestamp})
            if recentLogs == nil {
                completion?(true)
            }
            var injectedDosage = recentLogs!.reduce(0.0, {$0 + $1.dosage})
            for log in recentLogs! {
                let remainingTime = autoInfusionConfiguration.startTime.timeIntervalSince(log.timestamp)
                let toInjectDosage = ceil(remainingTime / autoInfusionConfiguration.timeInterval) * autoInfusionConfiguration.dosage
                if injectedDosage + toInjectDosage > safetyConfiguration.maxDailyDosage {
                    completion?(false)
                }
                injectedDosage -= log.dosage
            }
        }
        completion?(true)
    }
    
    func isSafe(
        dosage: Double,
        safetyConfiguration: InfusionSafetyConfiguration,
        completion: ((Bool) -> ())?
    ) {
        dataManager.getAllInfusionLogs() { logs, error in
            guard error == nil else {completion?(false);return}
            let recentLogs = logs?.filter({Date().timeIntervalSince($0.timestamp) < 3600 * 24}).sorted(by: {$0.timestamp < $1.timestamp})
            if recentLogs == nil {
                completion?(true)
            }
            let injectedDosage = recentLogs!.reduce(0.0, {$0 + $1.dosage})
            completion?(injectedDosage + dosage <= safetyConfiguration.maxDailyDosage)
        }
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
        dataManager.updateInfusionConfiguration(configuration: configuration, completion: nil)
        let timer = Timer(
            fire: configuration.startTime,
            interval: configuration.timeInterval * 60,
            repeats: true
        ) { timer in
            let startString = String(format: "a:%.2f", configuration.dosage)
            BluetoothManager.shared.writeValue(value: startString) { error in
                
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        completion?(nil)
    }
    
    func infuse(dosage: Double, completion: ((Error?) -> ())?) {
        guard state == .clear else {completion?(WCISCControllerError.controllerBusy);return}
        state = .infusing
        let startString = String(format: "i:%.2f", dosage)
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
            let tuple = value.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ":")[1].split(separator: ";").map({Double($0)!})
            let status = InfusionStatus(rawValue: Int(tuple[1]))!
            dataManager.saveInfusionLogs(
                logs: [InfusionLog(timestamp: Date(), dosage: tuple[0], status: status)]
            ) { error in
                guard error == nil else {return}
                if status != .done {
                    self.delegate?.automaticInfusionFailed(status: status)
                }
            }
        }
    }
    
    func centralStateUnavailable(state: CBManagerState) {
        delegate?.centralStateUnavailable(state: state)
    }
}
