//
//  InfusionLogTableViewController.swift
//  wcisc
//
//  Created by 李灿晨 on 2/21/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import UIKit
import SVProgressHUD

class InfusionLogTableViewController: UITableViewController {
    
    private var infusionLogs: [InfusionLog]? {
        didSet {
            guard infusionLogs != nil else {return}
            tableView.reloadData()
        }
    }
    private var dataManager = DataManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func loadInfusionLogs() {
        dataManager.getAllInfusionLogs() { logs, error in
            guard error == nil else {SVProgressHUD.showError(withStatus: "Data Storage Error");return}
            self.infusionLogs = logs
        }
    }

}

extension InfusionLogTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return infusionLogs?.count ?? 0
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infusionLogTableViewCell")!
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let cell = cell as! InfusionLogTableViewCell
        cell.infusionLog = infusionLogs?[indexPath.row]
    }
}
