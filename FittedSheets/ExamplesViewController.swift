//
//  ViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/16/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class ExamplesViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var sizesTextField: UITextField!
    @IBOutlet weak var halfScreenSwitch: UISwitch!
    @IBOutlet weak var fullScreenSwitch: UISwitch!
    @IBOutlet weak var adjustForBottomSafeAreaSwitch: UISwitch!
    @IBOutlet weak var blurBottomSafeAreaSwitch: UISwitch!
    @IBOutlet weak var dismissOnBackgroundTapSwitch: UISwitch!
    @IBOutlet weak var navigationControllerSwitch: UISwitch!
    @IBOutlet weak var useStockFirstInNavigationSwitch: UISwitch!
    @IBOutlet weak var extendBackgroundBehindHandleSwitch: UISwitch!
    @IBOutlet weak var roundedCornersSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addExample("Color Tests", controller: { ColorExampleViewController.instantiate() })
        addExample("Scroll View", controller: { ScrollViewExampleViewController.instantiate() })
        addExample("Table View", controller: { TableViewExampleViewController.instantiate() })
        addExample("Table View Controller", controller: { ExampleTableViewController.instantiate() })
        addExample("Intrinsic Height", controller: { IntrinsicExampleViewController.instantiate() })
        addExample("Self Resizing", controller: { ResizingExampleViewController.instantiate() })
    }
    
    func addExample(_ name: String, controller: @escaping () -> UIViewController) {
        let button = UIButton(type: .custom)
        button.setTitle(name, for: .normal)
        button.onTap { [weak self] in
            guard let self = self else { return }
            var controller = controller()
            let stringSizes = self.sizesTextField.text!.components(separatedBy: ",")
            var sizes: [SheetSize] = stringSizes.compactMap({
                Int($0.trimmingCharacters(in: .whitespacesAndNewlines))
            }).map({
                SheetSize.fixed(CGFloat($0))
            })
            if self.halfScreenSwitch.isOn {
                sizes.append(.halfScreen)
            }
            if self.fullScreenSwitch.isOn {
                sizes.append(.fullScreen)
            }
            
            if self.navigationControllerSwitch.isOn {
                if self.useStockFirstInNavigationSwitch.isOn {
                    controller = NavigationRootViewController.instantiate(exampleViewController: controller)
                }
                controller = UINavigationController(rootViewController: controller)
            }
            
            var pullBarOptions = SheetOptions()
            pullBarOptions.cornerRadius = self.roundedCornersSwitch.isOn ? 20 : 0
            
            let sheetController = SheetViewController(controller: controller, sizes: sizes)
            sheetController.dismissOnOverlayTap = self.dismissOnBackgroundTapSwitch.isOn
            
//            sheetController.willDismiss = { _ in
//                print("Will dismiss \(name)")
//            }
//            sheetController.didDismiss = { _ in
//                print("Will dismiss \(name)")
//            }
            
            self.present(sheetController, animated: false, completion: nil)
        }
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        
        self.stackView.addArrangedSubview(button)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func presentSheet1(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet1"))
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet2(_ sender: Any) {
        
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet2"), sizes: [.halfScreen, .fullScreen, .fixed(250)])
        
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet3(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet3"), sizes: [.fullScreen, .fixed(200)])
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet3v2(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet3"), sizes: [.fixed(100)])
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet4(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet4"), sizes: [.fixed(450), .fixed(300), .fixed(600), .fullScreen])
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet5(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet5"), sizes: [.fixed(450), .fixed(300), .fixed(160), .fullScreen])
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSelfSizingSheet(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "selfsizing"), sizes: [.fullScreen])
        self.present(controller, animated: false, completion: nil)
    }
}
