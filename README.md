# FittedSheets
Bottom sheets for iOS

Minimum requirement:  
![iOSVersion](https://img.shields.io/badge/iOS-9-green.svg) 
![SwiftVersion](https://img.shields.io/badge/Swift-4.2-green.svg) 
![XcodeVersion](https://img.shields.io/badge/Xcode-10-green.svg)  

## About
This project is to enable easily presenting view controllers in a bottom sheet that supports scrollviews and multiple sizes. Contributions and feedback are very welcome.  

The bottom sheet tries to be smart about the height it takes. If the view controller is smaller than the sizes specified, it will only grow as large as the intrensic height of the presented view controller. If it is larger, it will stop at each height specified in the initializer or setSizes function.

| Intrensic Heights | Fullscreen Modal | True Fullscreen | Scrolling | Inline |
|:-:|:-:|:-:|:-:|:-:|
| ![Intrensid Heights](IntrensicHeight.gif) | ![Fullscreen Modal](FullscreenHeight.gif) | ![True Fullscreen](TrueFullscreenHeight.gif) | ![Scrolling](Scrolling.gif) | ![Inline](Inline.gif) | 

## Usage

Some options can only be set when setting up the fitted sheets. These are set in the `SheetOptions` property of the constructor.

_The constructor is `init(controller:, sizes:, options:)`. Sizes is optional, but if specified, the first size in the array will determine the initial size of the sheet. Options is also optional, if not specified, the default options will be used._  

**Using default settings**  

```swift
import FittedSheets

let controller = MyViewController()

let sheetController = SheetViewController(controller: controller)

self.present(sheetController, animated: true, completion: nil) 
```

**Customizing settings**  

```swift
let controller = MyViewController()

let options = SheetOptions(
    // The full height of the pull bar. The presented view controller will treat this area as a safearea inset on the top
    pullBarHeight: 24,
    
    // The size of the grip in the pull bar
    gripSize: CGSize(width: 50, height: 6),
    
    // The color of the grip on the pull bar
    gripColor: UIColor(white: 0.868, alpha: 1),
    
    // The corner radius of the sheet
    cornerRadius: 20,
    
    // The corner radius of the shrunken presenting view controller
    presentingViewCornerRadius: 20, 
    
    // Extends the background behind the pull bar or not
    shouldExtendBackground: true,
    
    // Attempts to use intrensic heights on navigation controllers. This does not work well in combination with keyboards without your code handling it.
    setIntrensicHeightOnNavigationControllers: true, 
    
    // Pulls the view controller behind the safe area top, especially useful when embedding navigation controllers
    useFullScreenMode: true,
    
    // Shrinks the presenting view controller, similar to the native modal
    shrinkPresentingViewController: true,
    
    // Determines if using inline mode or not
    useInlineMode: false, 
    
    // minimum distance above the pull bar, prevents bar from coming right up to the edge of the screen
    minimumSpaceAbovePullBar: 0 
)

let sheetController = SheetViewController(
    controller: controller, 
    sizes: [.intrensic, .percent(0.25), .fixed(200), .fullScreen])
    
// Disable the dismiss on background tap functionality
sheetController.dismissOnOverlayTap = false

// Disable the ability to pull down to dismiss the modal
sheetController.dismissOnPull = false

/// Allow pulling past the maximum height and bounce back. Defaults to true.
sheetController.allowPullingPastMaxHeight = false

/// Automatically grow/move the sheet to accomidate the keyboard. Defaults to false.
sheetController.autoAdjustToKeyboard = false

// Color of the sheet anywhere the child view controller may not show (or is transparent), such as behind the keyboard currently
sheetController.contentBackgroundColor

// Change the overlay color
sheetController.overlayColor = UIColor.red

self.present(sheetController, animated: false, completion: nil)
```

**Handling dismiss events**
```swift
let sheet = SheetViewController(controller: controller, sizes: [.fixed(420), .fullScreen])
sheet.willDismiss = { _ in
// This is called just before the sheet is dismissed. Return false to prevent the build in dismiss events
    return true
}
sheet.didDismiss = { _ in
    // This is called after the sheet is dismissed
}
self.present(sheet, animated: false, completion: nil)
```

**

## Inline presentation  
_Starting with version 2.0.0, the ability to present inline was added. THis allows recreating behaviours like Maps_

```swift
let controller = MyViewController()

let options = SheetOptions(
    useInlineMode: true
)

let sheetController = SheetViewController(controller: controller, sizes: [.percent(0.3), .fullscreen], options: options)

// Add child
sheetController.willMove(toParent: self)
self.addChild(sheetController)
self.view.addSubview(sheetController.view)
sheetController.didMove(toParent: self)
Constraints(for: sheet.view) {
    $0.edges(.top, .left, .bottom, .right).pinToSuperview()
}

// animate in
sheet.animateIn()
```

## Scrolling

```swift
/// This should be called by any child view controller that expects the sheet to use be able to expand/collapse when the scroll view is at the top.
func handleScrollView(_ scrollView: UIScrollView)
```

There is an extension on UIViewController that gives you a `sheetViewController` that attempts to find the current SheetViewController so you can attach like this:

```swift
override func viewDidLoad() {
  super.viewDidLoad()
  
  self.sheetViewController!.handleScrollView(self.scrollView) // or tableView/collectionView/etc
}
```

## Package Management
We support [cocoapods](http://cocoapods.org/), carthage, and SPM.  

**Cocoapods**
Add this to your podfile to add FittedSheets to your project.  

```
pod 'FittedSheets'
```

**Carthage**
`TODO: Add carthage instructions`

**SPM**
`TODO: Add swift package manager instructions`

## License
FittedSheets uses the MIT License:

Please see included [LICENSE file](https://raw.githubusercontent.com/gordontucker/FittedSheets/master/LICENSE).
