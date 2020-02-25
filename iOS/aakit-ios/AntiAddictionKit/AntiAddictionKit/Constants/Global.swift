
import UIKit

let kContainerBackgroundColor: UIColor = UIColor(white: 0, alpha: 0.05)

let kContainerWidth: CGFloat = 290
let kContainerHeight: CGFloat = 280

let kDeviceHeight: CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
let kDeviceWidth: CGFloat = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)

let isPhone: Bool = (UIDevice.current.userInterfaceIdiom == .phone)
let isPad: Bool = (UIDevice.current.userInterfaceIdiom == .pad)
let isPhoneMax: Bool = (isPhone && kDeviceWidth == CGFloat(414))

let kContainerScale: CGFloat = (isPad ? 1.5 : (isPhoneMax ? 1.2 : 1.0))

func isPortrait() -> Bool {
    return (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)
}

func isLandscape() -> Bool {
    return (UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight)
}
