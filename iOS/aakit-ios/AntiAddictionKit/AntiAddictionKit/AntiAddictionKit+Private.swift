
import UIKit

enum AntiAddictionResult: Int {
    case loginSuccess = 500 //用户登录成功
    case logout = 1000 //用户切换账号
    
    case noPayLimit = 1020 // 无付费限制
    case hasPayLimit  = 1025 //有付费限制，无法付费
    
    case realNameRequest = 1060 //请求外部实名登记
    
    case realNameAuthSucceed = 1010 //实名成功
    case realNameAuthFailed = 1015 //实名失败
    
    
    case noRemainTime = 1030 //无剩余游戏时长
    
    case noChatLimit = 1080 //用户已实名，可聊天
    case hasChatLimit = 1090 //用户未实名，无法聊天
    
    case gamePause = 2000 //sdk页面打开，游戏暂停
    case gameResume = 2500 //sdkd页面关闭，游戏恢复
    
    
    func intValue() -> Int {
        return self.rawValue
    }
}

/// Private Methods
extension AntiAddictionKit {
    
    static var sharedDelegate: AntiAddictionCallback?
    
    class func isKitInstalled() -> Bool {
        if (AntiAddictionKit.sharedDelegate == nil) {
            Log("请先初始化 AAKit！")
            return false
        }
        return true
    }
    
    class func sendCallback(result: AntiAddictionResult, message: String?) {
        DispatchQueue.main.async {
            AntiAddictionKit.sharedDelegate?.onAntiAddictionResult(result.intValue(), message ?? "")
        }
    }
    
    class func addNotificationListener() {
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (notification) in
            DebugLog("游戏开始活跃")
            guard let _ = AntiAddictionKit.sharedDelegate else { return }
            TimeService.start()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (notification) in
            DebugLog("游戏开始不活跃")
            AlertTip.userTappedToDismiss = false
            guard let _ = AntiAddictionKit.sharedDelegate else { return }
            TimeService.stop()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (notification) in
            DebugLog("游戏进入后台")
            AlertTip.userTappedToDismiss = false
            guard let _ = AntiAddictionKit.sharedDelegate else { return }
            TimeService.stop()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: nil) { (notification) in
            DebugLog("游戏即将关闭")
            AlertTip.userTappedToDismiss = false
            guard let _ = AntiAddictionKit.sharedDelegate else { return }
            TimeService.stop()
        }

    }
    
}
