//
//  InfusionConfigurationTableViewController.swift
//  wcisc
//
//  Created by 李灿晨 on 3/3/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit

protocol InfusionConfigurationDelegate {
    func availableStateDidChange(available: Bool)
}

class InfusionConfigurationTableViewController: UITableViewController {

    @IBOutlet weak var dosageTextField: UITextField!
    @IBOutlet weak var autoInfuseSwitch: UISwitch!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var timeIntervalTextField: UITextField!
    @IBOutlet weak var maxDailyDosageTextField: UITextField!
    
    static var delegate: InfusionConfigurationDelegate?
    
    var isAutoInfuse: Bool {
        get {
            return autoInfuseSwitch.isOn
        }
    }
    
    var dosage: Double? {
        get {
            return Double(dosageTextField.text ?? "")
        }
    }
    var infuseConfiguration: AutoInfusionConfiguration? {
        if dosage == nil {return nil}
        if startTimePicker.date < Date() {return nil}
        let timeInterval = Double(timeIntervalTextField.text ?? "")
        if timeInterval != nil {
            return AutoInfusionConfiguration(
                startTime: startTimePicker.date,
                timeInterval: timeInterval!,
                dosage: dosage!
            )
        } else {
            return nil
        }
    }
    var safetyConfiguration: InfusionSafetyConfiguration? {
        get {
            let maxDailyDosage = Double(maxDailyDosageTextField.text ?? "")
            if maxDailyDosage == nil {
                return nil
            } else {
                return InfusionSafetyConfiguration(maxDailyDosage: maxDailyDosage!)
            }
            
        }
    }
    var isAvailable: Bool = false {
        didSet {
            if isAvailable != oldValue {
                InfusionConfigurationTableViewController.delegate?.availableStateDidChange(available: isAvailable)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimePicker.minimumDate = Date()
    }

    @IBAction func autoInfuseSwitch(_ sender: UISwitch) {
        tableView.beginUpdates()
        tableView.setNeedsLayout()
        tableView.endUpdates()
        updateAvailableStatus()
    }
    
    private func updateAvailableStatus() {
        if autoInfuseSwitch.isOn {
            isAvailable = infuseConfiguration != nil
        } else {
            isAvailable = dosage != nil
        }
    }
}

extension InfusionConfigurationTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 3) {
            if autoInfuseSwitch.isOn {
                if indexPath.row == 2 {
                    return 180
                } else if indexPath.row == 3 {
                    return 48
                }
            } else {
                return 0
            }
        }
        return 48
    }
}
