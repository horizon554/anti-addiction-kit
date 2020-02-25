
import Foundation

let kPaymentLimitAlertTitle: String = "健康消费提示"

/// 弹窗类型
public enum AlertType {
    /// 无限制
//    case unlimited
    /// 游戏时长限制
    case timeLimitAlert
    /// 支付限制
    case payLimitAlert
}

extension AlertType {
    enum TimeLimitAlertContent {
        case guestLogin(minutes: Int, isFirstLogin: Bool)
        case guestGameOver(minutes: Int)
        case minorGameOver(minutes: Int = 0, isCurfew: Bool)
        
        var title: String {
            return "健康游戏提示"
        }
        
        var body: String {
            switch self {
            case .guestLogin(let minutes, let isFirstLogin):
                let maxMinutes = max(1, minutes)
                if isFirstLogin {
                    return "您当前为游客账号，根据国家相关规定，游客账号享有 \(maxMinutes) 分钟游戏体验时间。登记实名信息后可深度体验。"
                } else {
                    return "您当前为游客账号，游戏体验时间还剩余 \(maxMinutes) 分钟。登记实名信息后可深度体验。"
                }
            case .guestGameOver(let minutes):
                let maxMinutes = max(1, minutes)
                return "您的游戏体验时长已达 \(maxMinutes) 分钟。登记实名信息后可深度体验。"
            case .minorGameOver(let minutes, let isCurfew):
                let maxMinutes = max(1, minutes)
                if isCurfew {
                    return "根据国家相关规定，每日 22 点 - 次日 8 点为健康保护时段，当前无法进入游戏。"
                } else {
                    return "您今日游戏时间已达 \(maxMinutes) 分钟。根据国家相关规定，今日无法再进行游戏。请注意适当休息。"
                }
            }
        }
        
    }
}

public struct AlertData {
    var type: AlertType
    var title: String
    var body: String
    var remainTime: Int
    
    init() {
        type = .timeLimitAlert
        title = ""
        body = ""
        remainTime = .max
    }
    
    init(type: AlertType, title: String, body: String, remainTime: Int = .max) {
        self.init()
        self.type = type
        self.title = title
        self.body = body
        self.remainTime = remainTime
    }
}
