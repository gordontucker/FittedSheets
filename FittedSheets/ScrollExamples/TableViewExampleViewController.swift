//
//  TableViewExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit

class TableViewExampleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sheetViewController?.handleScrollView(self.tableView)
    }

    static func instantiate() -> TableViewExampleViewController {
        return UIStoryboard(name: "ScrollExample", bundle: nil).instantiateViewController(withIdentifier: "tableView") as! TableViewExampleViewController
    }
}

extension TableViewExampleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row)"
        return cell
    }
}
