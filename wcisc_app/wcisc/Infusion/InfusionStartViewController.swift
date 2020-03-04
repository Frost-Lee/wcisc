//
//  InfusionStartViewController.swift
//  wcisc
//
//  Created by 李灿晨 on 3/3/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit

class InfusionStartViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension InfusionStartViewController: InfusionConfigurationDelegate {
    func availableStateDidChange(available: Bool) {
        startButton.isEnabled = available
    }
}
