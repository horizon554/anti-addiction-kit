
import UIKit

fileprivate let kAuthTipText = "根据国家相关要求，所有游戏用户须如实登记本人有效实名信息。如使用其他身份证件，可联系客服协助登记。"


final class AuthTip {
    
    // MARK: - Public
    public class func show(to view: UIView) {
        
        setPreferences()
        
        _sharedEasyTipView.dismiss {
            DispatchQueue.main.async {
                _sharedEasyTipView = EasyTipView(text: kAuthTipText, preferences: EasyTipView.globalPreferences, delegate: nil)
                _sharedEasyTipView.show(forView: view)
            }
        }
    }
    
    public class func hide() {
        _sharedEasyTipView.dismiss()
    }
    
    // MARK: - Private
    private static var _sharedEasyTipView: EasyTipView = EasyTipView(text: kAuthTipText, preferences: EasyTipView.globalPreferences, delegate: nil)
    
    private static func setPreferences() {
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont.systemFont(ofSize: Appearance.default.bodyFontSize)
        preferences.drawing.foregroundColor = Appearance.default.tipTextColor
        preferences.drawing.backgroundColor = Appearance.default.grayBackgroundColor
        preferences.drawing.textAlignment = .left
        preferences.animating.showDuration = 0.3
        preferences.animating.dismissDuration = 0.1
        
        preferences.drawing.arrowPosition = isPortrait() ? .top : .left
        preferences.positioning.maxWidth = isPortrait() ? 200 : 378
        preferences.drawing.arrowHeight = CGFloat(6)
        preferences.drawing.arrowWidth = CGFloat(12)
        preferences.positioning.bubbleHInset = CGFloat(0)
        preferences.positioning.bubbleVInset = CGFloat(0)
        
        EasyTipView.globalPreferences = preferences
    }
}
