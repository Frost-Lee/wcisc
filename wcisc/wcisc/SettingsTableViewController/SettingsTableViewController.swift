//
//  SettingsTableViewController.swift
//  wcisc
//
//  Created by 李灿晨 on 2/21/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var deviceNameTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceNameTextField.text = UserDefaults.standard.string(forKey: "deviceName")
        // Call textFieldDidChanged here?
    }
    
    @IBAction func textFieldDidChanged(_ sender: Any) {
        connectButton.isEnabled = deviceNameTextField.text != nil
    }
    
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(deviceNameTextField.text!, forKey: "deviceName")
        // Device connection code here
    }
}
