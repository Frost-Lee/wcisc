//
//  InformationPanelTableViewController.swift
//  wcisc
//
//  Created by 李灿晨 on 3/3/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit

class InformationPanelTableViewController: UITableViewController {

    @IBOutlet weak var deviceConnectedIndicatorImageView: UIImageView!
    @IBOutlet weak var injectionScheduledIndicatorImageView: UIImageView!
    
    @IBOutlet weak var autoInfusionStartTimeLabel: UILabel!
    @IBOutlet weak var autoInfusionDosageLabel: UILabel!
    @IBOutlet weak var autoInfusionIntervalLabel: UILabel!
    
    static var sharedInstance: InformationPanelTableViewController!
    
    private var wciscController = WCISCController.shared
    private var dataManager = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InformationPanelTableViewController.sharedInstance = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        if wciscController.deviceConnected {
            deviceConnectedIndicatorImageView.image = UIImage(systemName: "checkmark.circle")
            deviceConnectedIndicatorImageView.tintColor = .systemGreen
        } else {
            deviceConnectedIndicatorImageView.image = UIImage(systemName: "xmark.circle")
            deviceConnectedIndicatorImageView.tintColor = .systemRed
        }
        if wciscController.state == .runningAutomaticInfusion {
            injectionScheduledIndicatorImageView.image = UIImage(systemName: "checkmark.circle")
            injectionScheduledIndicatorImageView.tintColor = .systemGreen
            dataManager.getInfusionConfiguration() { configuration, error in
                guard error == nil else {return}
                self.autoInfusionStartTimeLabel.text = configuration?.startTime.formattedString(with: "yyyy.MM.dd HH:mm")
                self.autoInfusionDosageLabel.text = String(format: "%.1f", configuration!.dosage)
                self.autoInfusionIntervalLabel.text = String(format: "%.0f", configuration!.timeInterval)
            }
        } else {
            injectionScheduledIndicatorImageView.image = UIImage(systemName: "xmark.circle")
            injectionScheduledIndicatorImageView.tintColor = .systemRed
            autoInfusionStartTimeLabel.text = "-"
            autoInfusionDosageLabel.text = "-"
            autoInfusionIntervalLabel.text = "-"
        }
    }

}
