
import UIKit

fileprivate let kDefaultAlertTipText: String = "适度游戏益脑，沉迷游戏伤身，合理安排时间，享受健康生活。"

enum AlertTipType {
    case lessThan15Minutes(_ level: TimeLimitLevel, isCurfew: Bool = false)
    case lessThan60seconds(_ level: TimeLimitLevel, _ seconds: Int, isCurfew: Bool = false)
    
    var attributedString: NSAttributedString {
        
        switch self {
        case .lessThan15Minutes(let level, let isCurfew):
            let minutes = max(1, AntiAddictionKit.configuration.firstAlertTipRemainTime/kSecondsPerMinute)
            if level == .guest {
                return attributedAlertTipText("您的游戏体验时间还剩余 \(minutes) 分钟，登记实名信息后可深度体验。")
            } else if level == .minor {
                return isCurfew ? attributedAlertTipText("距离健康保护时间还剩余 \(minutes) 分钟，请注意适当休息。") : attributedAlertTipText("您今日游戏时间还剩余 \(minutes) 分钟，请注意适当休息。")
            }
            //成年人
            return attributedAlertTipText(kDefaultAlertTipText)
        case .lessThan60seconds(let level, let seconds, let isCurfew):
            if level == .guest {
                return attributedAlertTipText("您的游戏体验时间还剩余 \(seconds) 秒，登记实名信息后可深度体验。")
            } else if level == .minor {
                return isCurfew ? attributedAlertTipText("距离健康保护时间还剩余 \(seconds) 秒，请注意适当休息。") : attributedAlertTipText("您今日游戏时间还剩余 \(seconds) 秒，请注意适当休息。")
            }
            //成年人
            return attributedAlertTipText(kDefaultAlertTipText)
        }
    }
}


fileprivate func attributedAlertTipText(_ text: String) -> NSAttributedString {
    let attributedText = NSMutableAttributedString(string: text)
    
    let fullRange = text.fullRange()
    // 行间距
    let pStyle = NSMutableParagraphStyle()
    pStyle.paragraphSpacing = 4
    pStyle.lineSpacing = 4
    pStyle.alignment = .left
    attributedText.addAttribute(.paragraphStyle, value: pStyle, range: fullRange)
    
    attributedText.addAttribute(.foregroundColor, value: UIColor.white, range: fullRange)
    //等宽字体，防止文字切换时浮窗抖动
    attributedText.addAttribute(.font, value: UIFont(name: "Helvetica", size: 14) ??  UIFont.systemFont(ofSize: 14), range: fullRange)
    
    // 高亮“实名登记”
    let authText1 = "实名登记"
    let authText2 = "登记实名信息"
    if let authRange = text.range(of: authText1) {
        attributedText.addAttribute(.foregroundColor, value: RGBA(241, 73, 57, 1), range: NSRange(authRange, in: text))
    }
    if let authRange = text.range(of: authText2) {
        attributedText.addAttribute(.foregroundColor, value: RGBA(241, 73, 57, 1), range: NSRange(authRange, in: text))
    }
    
    return attributedText
}

final class AlertTip {
    
    
    /// 是否用户手动关闭
    static var userTappedToDismiss: Bool = false
    
    class func show(_ type: AlertTipType) {
        switch type {
        case .lessThan60seconds(_, _, isCurfew: _):
            if userTappedToDismiss {
                DebugLog("用户手动关闭过60s浮窗，因此不再显示倒计时浮窗")
                return
            }
        default:
            break
        }
        
        DebugLog("展示防沉迷浮窗")
        let attStr = type.attributedString
        DebugLog(attStr.string)
        DispatchQueue.main.async {
            NoticeViewPresenter.show(attStr)
        }
    }
    
    class func hide() {
        DispatchQueue.main.async {
            NoticeViewPresenter.hide()
        }
    }
}
