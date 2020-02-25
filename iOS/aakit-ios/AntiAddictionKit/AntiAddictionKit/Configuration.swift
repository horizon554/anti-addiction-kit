
import Foundation

/// AAKit 功能配置
@objcMembers
@objc(Configuration)
public final class Configuration: NSObject {
    
    /// AAKit 实名登记开关，默认值为 true
    public var useSdkRealName: Bool = true
    
    /// AAKit 在线时长限制开关，默认值为 true
    public var useSdkOnlineTimeLimit: Bool = true
    
    /// AAKit 支付限制开关，默认值为 true
    public var useSdkPaymentLimit: Bool = true
    
    /// AAKit 切换账号按钮是否显示
    public var showSwitchAccountButton: Bool = true
    
    /// 未成年人非节假日每日总时长
    #if DEBUG
    public var minorCommonDayTotalTime: Int = 90 * 60
    #else
    public var minorCommonDayTotalTime: Int = 90 * 60
    #endif
    
    /// 未成年人节假日每日总时长
    #if DEBUG
    public var minorHolidayTotalTime: Int = 180 * 60
    #else
    public var minorHolidayTotalTime: Int = 180 * 60
    #endif
    
    /// 游客每日总时长（无节假日区分）
    #if DEBUG
    public var guestTotalTime: Int = 60 * 60
    #else
    public var guestTotalTime: Int = 60 * 60
    #endif
    
    /// 展示剩余游戏时间浮窗时的剩余时长
    #if DEBUG
    public var firstAlertTipRemainTime: Int = 15 * 60
    #else
    public var firstAlertTipRemainTime: Int = 15 * 60
    #endif
    
    /// 展示倒计时浮窗时的剩余时长
    #if DEBUG
    public var countdownAlertTipRemainTime: Int = 60
    #else
    public var countdownAlertTipRemainTime: Int = 60
    #endif
    
    
    /// 宵禁开始时间（整数，小时，24小时进制，默认22）
    #if DEBUG
    public var curfewHourStart: Int = 22
    #else
    public var curfewHourStart: Int = 22
    #endif
    
    /// 宵禁结束时间（整数，小时，24小时进制，默认8）
    public var curfewHourEnd: Int = 8
    
    /// 8-15岁单笔付费额度限制，单位分（默认5000分）
    public var singlePaymentAmountLimitJunior: Int = 50 * 100
    
    /// 8-15岁每月总付费额度限制，单位分（默认20000分）
    public var mouthTotalPaymentAmountLimitJunior: Int = 200 * 100
    
    /// 16-17岁单笔付费额度限制，单位分（默认10000分）
    public var singlePaymentAmountLimitSenior: Int = 100 * 100
    
    /// 16-17岁每月总付费额度限制，单位分（默认40000分）
    public var mouthTotalPaymentAmountLimitSenior: Int = 400 * 100
    
    //外部禁用初始化方法
    internal override init() {
        super.init()
    }
    
}

