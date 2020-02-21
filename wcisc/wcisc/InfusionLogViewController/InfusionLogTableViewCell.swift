//
//  InfusionLogTableViewCell.swift
//  wcisc
//
//  Created by 李灿晨 on 2/20/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit

class InfusionLogTableViewCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var dosageLabel: UILabel!
    
    var infusionLog: InfusionLog? {
        didSet {
            guard infusionLog != nil else {return}
            setInfusionLog()
        }
    }
    
    private func setInfusionLog() {
        statusLabel.text = infusionLog!.status.indicateText()
        timestampLabel.text = infusionLog!.timestamp.formattedString(with: "yyyy.MM.dd hh:mm")
        dosageLabel.text = infusionLog!.dosage.unitString()
    }

}
