//
//  ExampleTableViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit

class ExampleTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // viewDidLoad happens before being added as a subview
        self.sheetViewController?.handleScrollView(self.tableView)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
     cell.textLabel?.text = "Row \(indexPath.row)"
     return cell
    }

    static func instantiate() -> ExampleTableViewController {
        return UIStoryboard(name: "ScrollExample", bundle: nil).instantiateViewController(withIdentifier: "tableViewController") as! ExampleTableViewController
    }
}
