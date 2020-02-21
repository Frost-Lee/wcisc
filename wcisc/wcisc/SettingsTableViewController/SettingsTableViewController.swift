//
//  SettingsTableViewController.swift
//  wcisc
//
//  Created by 李灿晨 on 2/21/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit
import SVProgressHUD

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var deviceNameTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceNameTextField.text = UserDefaults.standard.string(forKey: "deviceName")
        textFieldDidChanged(0)
    }
    
    @IBAction func textFieldDidChanged(_ sender: Any) {
        connectButton.isEnabled = (deviceNameTextField.text ?? "").count != 0
    }
    
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "Connecting")
        UserDefaults.standard.set(deviceNameTextField.text!, forKey: "deviceName")
        // Device connection code here
        SVProgressHUD.showSuccess(withStatus: "Connected")
    }
}

extension SettingsTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
