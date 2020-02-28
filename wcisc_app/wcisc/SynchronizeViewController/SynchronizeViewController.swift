//
//  SynchronizeViewController.swift
//  wcisc
//
//  Created by 李灿晨 on 2/19/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit
import SVProgressHUD

class SynchronizeViewController: UIViewController {

    @IBOutlet weak var minInfusionIntervalTextField: UITextField!
    @IBOutlet weak var maxSingleDosageTextField: UITextField!
    @IBOutlet weak var maxDailyDosageTextField: UITextField!
    @IBOutlet weak var synchronizeButton: UIButton!
    
    private var inputAvailable: Bool = false {
        didSet {
            synchronizeButton.isEnabled = inputAvailable
        }
    }
    private var infusionConfiguration: InfusionConfiguration? {
        didSet {
            guard infusionConfiguration != nil else {return}
            minInfusionIntervalTextField.text = String(format: "%.2f", infusionConfiguration!.minInfusionInterval)
            maxSingleDosageTextField.text = String(format: "%.2f", infusionConfiguration!.maxSingleDosage)
            maxDailyDosageTextField.text = String(format: "%.2f", infusionConfiguration!.maxDailyDosage)
            textFieldChanged(0)
        }
    }
    
    private var dataManager = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfusionConfiguration()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        view.endEditing(true)
    }

    @IBAction func synchronizeButtonTapped(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "Synchronizing")
        infusionConfiguration = InfusionConfiguration(
            minInfusionInterval: Double(minInfusionIntervalTextField.text!)!,
            maxSingleDosage: Double(maxSingleDosageTextField.text!)!,
            maxDailyDosage: Double(maxDailyDosageTextField.text!)!
        )
        dataManager.updateInfusionConfiguration(configuration: infusionConfiguration!) { error in
            guard error == nil else {SVProgressHUD.showError(withStatus: "Data Storage Error");return}
            // Bluetooth synchronization code here
            SVProgressHUD.showSuccess(withStatus: "Synchronized")
        }
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        guard
            Double(minInfusionIntervalTextField.text ?? "na") != nil &&
            Double(maxSingleDosageTextField.text ?? "na") != nil &&
            Double(maxDailyDosageTextField.text ?? "na") != nil
        else {inputAvailable = false; return}
        // Apply more complex logics to check the input here
        inputAvailable = true
    }
    
    private func loadInfusionConfiguration() {
        dataManager.getInfusionConfiguration() { configuration, error in
            guard error == nil else {SVProgressHUD.showError(withStatus: "Data Storage Error");return}
            self.infusionConfiguration = configuration
        }
    }
    
}
