//
//  ExampleTableViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class TableViewControllerDemo: UITableViewController, Demoable {
    static var name: String { "TableViewController" }
    
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

    static func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = UIStoryboard(name: "TableViewControllerDemo", bundle: nil).instantiateInitialViewController()!
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(0.25), .fullscreen],
            options: SheetOptions(useInlineMode: useInlineMode))
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
