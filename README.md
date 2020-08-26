# 📱 BitPageControl
**BitPageControl** is an open source library which provides a PageControl with filling animation.
You can easily override the public attributes to get your desired effects.


# 🕹 USAGE

- To start you need to import `BitPageControl` inside your `ViewController`.
```
import BitPageControl
```
- Create a `UIView` object either in the `storyBoard` or in the code, and set its type to: `BitPageControlWithTiming`.
- Inside the `viewDidLoad` method, setup the `BitPageControl`, the only required attribute is `numberOfPages`, follow the guide below for more options.

```
@IBOutlet var pageControl: BitPageControlWithTiming!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // * Required - Number of indicators
        self.pageControl.numberOfPages = self.dataSource.count 
        
        // * Optional - Spacing between indicators
        self.pageControl.spacing = 8
        
        // * Optional - If you want the indicators to play automatically one after another.
        self.pageControl.autoPlay = true 
        
        // * Optional - You can define different fill animation duration for each indicator, or a common duration for all the indicators.
        self.pageControl.setFillingDurationForIndicators([1.5, 2.0]) 
        
        // * Optional - The time it takes for an indicator to collapse to its original size.
        self.pageControl.indicatorCollapseAnimationDuration = 0.2 
        
        // * Optional - The filled color.
        self.pageControl.currentPageIndicatorTintColor = .blue
        
         // * Optional - Indicator inactive color.
        self.pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.6569468379, green: 0.6434265971, blue: 0.9577060342, alpha: 1)
        
        // * Optional - If you need to inform your View when an indicator has been tapped or the process has been finished, you need to conform to the BitPageControlWithTimingDelegate and set the delegate to the viewController responsible for making decision.
        self.pageControl.delegate = self
        
        // * Optional - Add a target to get notified when indicator page has been changed.
        self.pageControl.addTarget(self, action: #selector(pageDidChange), for: .valueChanged)
    }
```


# 🖼 Example

Inside the library there is an example project which you can run and test the behaviour.


# ⚙️ Installation

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

You can install it with the following command:
```
$ gem install cocoapods
```
To integrate **BitPageControl** into your Xcode project using CocoaPods, specify it in your `Podfile`:
```
use_frameworks!

pod 'BitPageControlWithTiming', '~> 0.0'
```


# 🧪 Demo

![Alt text](/BitPageControl-screenshot.gif?raw=true "Screenshot")



