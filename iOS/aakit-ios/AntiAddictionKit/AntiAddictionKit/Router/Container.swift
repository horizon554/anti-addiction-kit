
import UIKit

class Container: UIViewController {
    
    // MARK: - Public
    private static var _shared: Container? = Container()
    public class func shared() -> Container {
        if (_shared == nil) {
            _shared = Container()
        }
        return _shared!
    }
    
    public func setupVC(_ vc: BaseController) {
        Container.shared().setContent(vc)
        Container.shared().modalPresentationStyle = .custom
        Container.shared().view.backgroundColor = kContainerBackgroundColor
    }
    
    // MARK: - Private
    private func setContent(_ vc: BaseController) {
        if children.count > 0 {
            for child in children {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
        
        let navigator = Navigator(rootViewController: vc)
        
        addChild(navigator)
        view.addSubview(navigator.view)
        navigator.didMove(toParent: self)
        
        navigator.view.addCenterXYConstraint(toView: view)
        navigator.view.addWidthAndHeightConstraint(width: kContainerWidth, height: kContainerHeight)
        
        navigator.view.layer.cornerRadius = 8
        navigator.view.clipsToBounds = true
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGR)
    }
    
    @objc
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    deinit {
        DebugLog("Container Deinit")
    }
    
}
