//
//  InfusionStartViewController.swift
//  wcisc
//
//  Created by 李灿晨 on 3/3/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol InfusionStartDelegate {
    func controllerWillDismiss()
}

class InfusionStartViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    
    var delegate: InfusionStartDelegate?
    
    private var wciscController = WCISCController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InfusionConfigurationTableViewController.sharedInstance.delegate = self
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        func showSafetyAlert() {
            DispatchQueue.main.async {
                let alertController = UIAlertController(
                    title: "Safety Warning",
                    message: "The current infusion is refused because it breaks the safety rule.",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: {alert in alertController.dismiss(animated: true, completion: nil)}
                ))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        let configurationController = InfusionConfigurationTableViewController.sharedInstance!
        if configurationController.isAutoInfuse {
            wciscController.isSafe(
                autoInfusionConfiguration: configurationController.infuseConfiguration!,
                safetyConfiguration: configurationController.safetyConfiguration!
            ) { isSafe in
                if isSafe {
                    SVProgressHUD.show(withStatus: "Starting")
                    self.wciscController.configure(
                        configuration: configurationController.infuseConfiguration!
                    ) { error in
                        if error == nil {
                            self.wciscController.automaticInfuse(
                                configuration: configurationController.infuseConfiguration!
                            ) { error in
                                if error == nil {
                                    SVProgressHUD.showSuccess(withStatus: "Auto-Infusion started")
                                    self.delegate?.controllerWillDismiss()
                                    self.dismiss(animated: true, completion: nil)
                                } else {
                                    SVProgressHUD.showError(withStatus: "Auto-Infusion start failed")
                                }
                            }
                        } else {
                            SVProgressHUD.showError(withStatus: "Auto-Infusion start failed")
                        }
                    }
                } else {
                    showSafetyAlert()
                }
            }
        } else {
            wciscController.isSafe(
                dosage: configurationController.dosage!,
                safetyConfiguration: configurationController.safetyConfiguration!
            ) { isSafe in
                if isSafe {
                    SVProgressHUD.show(withStatus: "Starting")
                    self.wciscController.infuse(
                        dosage: configurationController.dosage!
                    ) { error in
                        if error == nil {
                            SVProgressHUD.showSuccess(withStatus: "Infusion started")
                            self.delegate?.controllerWillDismiss()
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            SVProgressHUD.showError(withStatus: "Infusion start failed")
                        }
                    }
                } else {
                    showSafetyAlert()
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        delegate?.controllerWillDismiss()
        dismiss(animated: true, completion: nil)
    }
    
}

extension InfusionStartViewController: InfusionConfigurationDelegate {
    func availableStateDidChange(available: Bool) {
        startButton.isEnabled = available
    }
}
