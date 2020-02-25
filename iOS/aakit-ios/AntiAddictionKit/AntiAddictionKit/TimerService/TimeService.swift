
import Foundation


/// 每分钟60秒
let kSecondsPerMinute: Int = 60
/// Timer 执行间隔
fileprivate let kTimerInterval: Int = 1

final class TimeService {
    
    /// 开始防沉迷时长统计服务
    class func start() {
        if AntiAddictionKit.configuration.useSdkOnlineTimeLimit == false {
            DebugLog("游戏未开启防沉迷时长统计")
            return
        }
        
        guard User.shared != nil else {
            DebugLog("无用户，无法启动防沉迷时长统计")
            return
        }
        
        if Router.isContainerPresented || Container.shared().isBeingPresented {
            DebugLog("防沉迷页面正在展示，无需统计")
            return
        }
        
        let limitLevel = TimeLimitLevel.limitLevelForUser(User.shared!)
        
        //成年人
        if limitLevel == .unlimited  {
            DebugLog("成年用户，无需统计时长")
            return
        }
        
        //如果最后一次存储的日期 与 现在不是同一天，则清空在线时长
        if (DateHelper.isSameDay(User.shared!.timestamp, Date()) == false) {
            User.shared!.clearOnlineTime()
        }
        
        DebugLog("防沉迷时长统计开始")
        
        mainTimer.start()
    }
    
    /// 停止防沉迷时长统计服务
    class func stop() {
        UserService.saveCurrentUserInfo()
        
        mainTimer.suspend()
    }
    
    /// 主 Timer
    private static var mainTimer: SwiftTimer = SwiftTimer(interval: .seconds(Int(kTimerInterval)), repeats: true, queue: .global()) { (mTimer) in
        
        DebugLog("Main Timer 任务执行一次！")
        
        guard User.shared != nil else {
            DebugLog("当前无登录用户，Timer 已暂停！")
            mTimer.suspend()
            return
        }
        
        let limitLevel = TimeLimitLevel.limitLevelForUser(User.shared!)
        
        //成年人
        if limitLevel == .unlimited  {
            DebugLog("成年用户，无需统计时长！")
            mTimer.suspend()
            return
        }
        
        User.shared!.onlineTimeIncrease(kTimerInterval)
        postOnlineTimeNotification()
        
        //游客
        if limitLevel == .guest {
        //游客不区分节假日
            let guestTotalTime: Int = AntiAddictionKit.configuration.guestTotalTime
            let guestTotalMinutes: Int = max(1, guestTotalTime/kSecondsPerMinute)
            let remainSeconds: Int = guestTotalTime - User.shared!.totalOnlineTime
            
            assert(guestTotalTime >= 0, "游客设定总时长不能为负数！！！")
            assert(remainSeconds >= 0, "用户剩余时间不能为负数！！！")
            
            // 没时间了
            if remainSeconds <= 0 {
                DebugLog("游客用户，没时间了，弹窗")
                mTimer.suspend()
                Router.closeAlertTip()
                
                AntiAddictionKit.sendCallback(result: .noRemainTime, message: "游客用户游戏时长限制")
                
                let content = AlertType.TimeLimitAlertContent.guestGameOver(minutes: guestTotalMinutes)
                Router.openAlertController(AlertData(type: .timeLimitAlert,
                                                     title: content.title,
                                                     body: content.body,
                                                     remainTime: 0),
                                           forceOpen: true)
                
                return
            }
            
            //小于设定时间（默认1分钟），倒计时浮窗
            if remainSeconds > 0 && remainSeconds <= AntiAddictionKit.configuration.countdownAlertTipRemainTime  {
                DebugLog("游客倒计时提示")
                Router.openAlertTip(.lessThan60seconds(.guest, remainSeconds))
                return
            }
            
            //15分钟时弹出 AlertTip
            if (remainSeconds) == AntiAddictionKit.configuration.firstAlertTipRemainTime {
                DebugLog("游客15分钟提示")
                Router.openAlertTip(.lessThan15Minutes(.guest, isCurfew: false))
                return
            }
            
            return
        }
        
        //剩下是未成年人
        if limitLevel == .minor {
            
            //判断当前时间与宵禁时间的距离是否==15分钟 或者 0分钟
            //如果是宵禁，无法游戏，给游戏发送无游戏时间通知
            if DateHelper.isCurfew(Date()) {
                //宵禁无法进入
                DebugLog("当前为宵禁时间，弹窗")
                
                AntiAddictionKit.sendCallback(result: .noRemainTime, message: "宵禁时间，无法进入游戏！")
                
                let content = AlertType.TimeLimitAlertContent.minorGameOver(isCurfew: true)

                Router.openAlertController(AlertData(type: .timeLimitAlert,
                                                     title: content.title,
                                                     body: content.body,
                                                     remainTime: 0))
                
                return
            }
            
            //距离宵禁的时间a
            let intervalForNextCurfew: Int = DateHelper.intervalForNextCurfew()
            
            //根据总时长限制计算出剩余时间b
            let minorTotalTime: Int = DateHelper.isHoliday(Date()) ? AntiAddictionKit.configuration.minorHolidayTotalTime : AntiAddictionKit.configuration.minorCommonDayTotalTime
            let minorTotalMinutes: Int = max(1, minorTotalTime/kSecondsPerMinute)
            let minorRemainSeconds: Int = minorTotalTime - User.shared!.totalOnlineTime
            
            //判断a，b哪个更小
            let isCurfew: Bool = intervalForNextCurfew < minorRemainSeconds
            let minimumRemainSeconds: Int = isCurfew ? intervalForNextCurfew : minorRemainSeconds
            
            
            assert(minorTotalTime >= 0, "未成年人设定总时长不能为负数！！！")
            assert(minorRemainSeconds >= 0, "用户剩余时间不能为负数！！！")
            assert(intervalForNextCurfew >= 0, "当前距宵禁时间不能为负数！！！")
            
            //没时间了，直接弹窗
            if (minimumRemainSeconds <= 0) {
                DebugLog("未成年用户，没时间了，弹窗")
                mTimer.suspend()
                Router.closeAlertTip()
                
                AntiAddictionKit.sendCallback(result: .noRemainTime, message: "未成年用户游戏时长限制/宵禁")
                
                let content = AlertType.TimeLimitAlertContent.minorGameOver(minutes: minorTotalMinutes, isCurfew: isCurfew)
                Router.openAlertController(AlertData(type: .timeLimitAlert,
                                                     title: content.title,
                                                     body: content.body,
                                                     remainTime: 0), forceOpen: true)
                
                return
            }
            
            //小于设定间隔，启动 countdown timer
            if minimumRemainSeconds > 0 && minimumRemainSeconds <= AntiAddictionKit.configuration.countdownAlertTipRemainTime  {
                DebugLog("未成年倒计时提示")
                Router.openAlertTip(.lessThan60seconds(.minor, minimumRemainSeconds, isCurfew: isCurfew))
                return
            }
            
            //判断15分钟
            if (minimumRemainSeconds == AntiAddictionKit.configuration.firstAlertTipRemainTime) {
                DebugLog("未成年15分钟提示")
                Router.openAlertTip(.lessThan15Minutes(.minor, isCurfew: isCurfew))
                return
            }
            
        }
        
    }
    
}

enum TimeLimitLevel {
    case guest //游客限制
    case minor //未成年限制
    case unlimited //成年人无限制
    
    static func limitLevelForUser(_ user: User) -> TimeLimitLevel {
        switch user.type {
        case .unknown:
            return .guest
        case .child, .junior, .senior:
            return .minor
        case .adult:
            return .unlimited
        }
    }
}

extension TimeService {
    
    /// Debug: - 给 DEMO 发送玩家当前游戏时间
    class func postOnlineTimeNotification() {
        if let user = User.shared {
            NotificationCenter.default.post(name: NSNotification.Name("NSNotification.Name.totalOnlineTime"), object: nil, userInfo: ["userId": user.id, "totalOnlineTime": user.totalOnlineTime])
        }
    }
}
