//
//  InfusionViewController.swift
//  wcisc
//
//  Created by 李灿晨 on 2/19/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit
import CoreBluetooth
import SVProgressHUD

class InfusionViewController: UIViewController {
    
    @IBOutlet weak var configureButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    private var wciscController = WCISCController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wciscController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "showInfusionStartViewController":
            let vc = (segue.destination as! UINavigationController).topViewController! as! InfusionStartViewController
            vc.delegate = self
        default:
            break
        }
    }
    
    @IBAction func configureButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showInfusionStartViewController", sender: nil)
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "Stopping")
        wciscController.stopInfusion() { error in
            if error == nil {
                SVProgressHUD.showSuccess(withStatus: "Stopped")
            } else {
                SVProgressHUD.showError(withStatus: "Stop Failed")
            }
            self.reloadData()
        }
    }
    
    func reloadData() {
        InformationPanelTableViewController.sharedInstance.reloadData()
        configureButton.isEnabled = (wciscController.state == .clear && wciscController.deviceConnected)
    }
}

extension InfusionViewController: InfusionStartDelegate {
    func controllerWillDismiss() {
        reloadData()
    }
}

extension InfusionViewController: WCISCControllerDelegate {
    func centralStateUnavailable(state: CBManagerState) {
        let alertController = UIAlertController(
            title: "Connection Error",
            message: "Cannot connect to peripheral device, error code: \(state.rawValue).",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: {alert in alertController.dismiss(animated: true, completion: nil)}
        ))
    }
    
    func automaticInfusionFailed(status: InfusionStatus) {
        let alertController = UIAlertController(
            title: "Auto-Infusion Failed",
            message: status.indicateText(),
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: {alert in alertController.dismiss(animated: true, completion: nil)}
        ))
        present(alertController, animated: true, completion: nil)
    }
}
