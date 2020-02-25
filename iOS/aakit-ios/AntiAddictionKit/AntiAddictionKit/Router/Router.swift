
import Foundation
import UIKit

class Router {
    
    // MARK: - Public
    
    public static var isContainerPresented: Bool = false
    
    public class func closeContainer() {
        DispatchQueue.main.async {
            let container = Container.shared()
            container.dismiss(animated: false, completion: nil)
        }
        self.isContainerPresented = false
    }
    
    public class func openAlertController(_ data: AlertData, forceOpen: Bool = true, isHsqjCheckCurrentPayLimit: Bool = false) {
        DispatchQueue.main.async {
            let alertController = AlertController(data, isHsqjCheckCurrentPayLimit: isHsqjCheckCurrentPayLimit)
            Router.openViewController(vc: alertController, forceOpen: forceOpen)
        }
        DebugLog("弹窗提醒已经打开，tpye=\(data.type)")
    }
    
    public class func openRealNameController(backButtonEnabled flag: Bool, forceOpen: Bool = false, cancelled: (() -> Void)? = nil, succeed: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let realnameController = RealNameController(backButtonEnabled: flag, cancelled: cancelled, succeed: succeed)
            Router.openViewController(vc: realnameController, forceOpen: forceOpen)
        }
        DebugLog("实名窗口已经打开")
    }
    
    public class func openAlertTip(_ type: AlertTipType) {
        AlertTip.show(type)
    }
    
    public class func closeAlertTip() {
        AlertTip.hide()
    }
    
    
    // MARK: - Private
    private class func openViewController(vc: BaseController, forceOpen: Bool = false) {
        //非强制开启，即当前已有sdk页面展示时，则不展示新页面
        //强制开启，则直接用新页面覆盖老页面
        
        
        if forceOpen == false {
            //非强制
            if (Router.isContainerPresented || Container.shared().isBeingPresented) {
                return
            }
        }
        
        //强制
        DispatchQueue.main.asyncAfter(deadline: 0.2) {
            guard let topVC = UIApplication.topViewController() else { return }
            Container.shared().setupVC(vc)
            if (Router.isContainerPresented == false && Container.shared().isBeingPresented == false) {
                topVC.present(Container.shared(), animated: false, completion: nil)
            }
            Router.isContainerPresented = true
        }
    }
    
}
