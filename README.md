# FittedSheets
Bottom sheets for iOS

Minimum requirement:  
![iOSVersion](https://img.shields.io/badge/iOS-10.3-green.svg) 
![SwiftVersion](https://img.shields.io/badge/Swift-4.2-green.svg) 
![XcodeVersion](https://img.shields.io/badge/Xcode-10-green.svg)  

![Demo](https://raw.githubusercontent.com/gordontucker/FittedSheets/master/fullDemo.gif)  

## About
This project is to enable easily presenting view controllers in a bottom sheet that supports scrollviews and multiple sizes. Contributions and feedback are very welcome.  

The bottom sheet tries to be smart about the height it takes. If the view controller is smaller than the sizes specified, it will only grow as large as the intrensic height of the presented view controller. If it is larger, it will stop at each height specified in the initializer or setSizes function.

## Usage
Using a bottom sheet is simple. 

_The constructor is `init(controller:, sizes:)`. Sizes is optional, but if specified, the first size in the array will determine the initial size of the sheet._  

**Using default settings**  

```swift
let controller = MyViewController()

let sheetController = SheetViewController(controller: controller)

self.present(sheetController, animated: false, completion: nil)
```

**Customizing settings**  

```swift
let controller = MyViewController()

let sheetController = SheetViewController(controller: controller, sizes: [.fixed(100), .fixed(200), .halfScreen, .fullScreen])
sheetController.blurBottomSafeArea = false
sheetController.adjustForBottomSafeArea = true

self.present(controller, animated: false, completion: nil)
```

## Settings

```swift
/// Determines if we should inset the view controller to account for the bottom safe area.
/// If your view controller already handles this, leave it false (the default)
/// If your view controller does *not* handle this, set it to true
var adjustForBottomSafeArea: Bool = false
```

```swift
/// Determines if we blur the contents under the bottom safe area (if there is a safe area)
/// The default value is true
var blurBottomSafeArea: Bool = true
```

```swift
/// The color of the overlay above the sheet.
var overlayColor: UIColor = UIColor(white: 0, alpha: 0.7)
```

```swift
/// Sets the heights the sheets will try to stick to. It will not resize the current size, but will affect all future resizing of the sheet.
func setSizes(_ sizes: [SheetSize])
```

```swift
/// This should be called by any child view controller that expects the sheet to use be able to expand/collapse when the scroll view is at the top.
func handleScrollView(_ scrollView: UIScrollView)
```

There is an extension on UIViewController that gives you a `sheetViewController` that attempts to find the current SheetViewController so you can attach like this:

```swift
override func viewDidLoad() {
  super.viewDidLoad()
  
  self.sheetViewController?.handleScrollView(self.scrollView) // or tableView/collectionView/etc
}
```

## Cocoapods
The easiest way to integrate the project is through [cocoapods](http://cocoapods.org/).  
Add this to your podfile to add FittedSheets to your project.  

```
pod 'FittedSheets'
```

## License
FittedSheets uses the MIT License:

Please see included [LICENSE file](https://raw.githubusercontent.com/gordontucker/FittedSheets/master/LICENSE).
