
import Foundation

final class RealNameService {
    
    class func openRealname() {
        if User.shared == nil {
            print("用户无登录用户")
            return
        }
        
        if AntiAddictionKit.configuration.useSdkRealName {
            Router.openRealNameController(backButtonEnabled: false, forceOpen: true, cancelled: {
                
            }, succeed: nil)
        } else {
            AntiAddictionKit.sendCallback(result: .realNameRequest, message: "请求打开实名界面")
        }
    }
}
