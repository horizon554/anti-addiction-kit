
import Foundation

final class ChatService {
    
    class func checkChatLimit() {
        //检查是否实名
        guard let user = User.shared else {
            AntiAddictionKit.sendCallback(result: .hasChatLimit, message: "当前无用户登录，无法聊天")
            return
        }
        
        if user.type == .unknown {
            
            //使用sdk实名
            if AntiAddictionKit.configuration.useSdkRealName {
                Router.openRealNameController(backButtonEnabled: false, cancelled: {
                    AntiAddictionKit.sendCallback(result: .hasChatLimit, message: "用户取消实名，无法聊天")
                }) {
                    AntiAddictionKit.sendCallback(result: .noChatLimit, message: "用户实名登记成功，可以聊天")
                }
            } else {
                //使用外部实名
                AntiAddictionKit.sendCallback(result: .realNameRequest, message: "用户未实名登记无法聊天，请求实名登记")
            }
            
        } else {
            AntiAddictionKit.sendCallback(result: .noChatLimit, message: "用户已实名，可以聊天")
        }
    }
    
}
