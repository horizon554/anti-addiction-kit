
import Foundation

final class DateHelper {
    
    //禁用初始化方法
    @available(*, unavailable)
    init() {
        fatalError("DateHelper-init is unavailable")
    }
    
    
    /// get Date? (instance or nil) from yyyyMMdd style string
    /// - Parameter from: yyyyMMdd style string
    class func dateFromyyyMMdd(_ from: String) -> Date? {
        return Date(fromString: from, format: .custom("yyyyMMdd"))
    }
    
    
    /// 是否同一天
    class func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        return lhs.compare(.isSameDay(as: rhs))
    }
    
    /// 是否同一月
    class func isSameMonth(_ lhs: Date, _ rhs: Date) -> Bool {
        return lhs.compare(.isSameMonth(as: rhs))
    }
    
    
    /// get age from yyyyMMdd
    class func getAge(_ dateString: String) -> Int {
        guard let date = self.dateFromyyyMMdd(dateString) else { return -1 }
        
        // 出生时间 年月日
        let birthYear = Calendar.current.component(.year, from: date)
        let birthMouth = Calendar.current.component(.month, from: date)
        let birthDay = Calendar.current.component(.day, from: date)
        
        // 当前时间 年月日
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMouth = Calendar.current.component(.month, from: Date())
        let currentDay = Calendar.current.component(.day, from: Date())
        
        var age: Int = currentYear - birthYear
        //如果当前日月<出生日月
        if ((birthMouth > currentMouth) || (birthMouth == currentMouth && birthDay > currentDay)){
            age -= 1
        }

        return age
    }
    
}

extension DateHelper {
    
    /// 判断是否宵禁时间
    class func isCurfew(_ date: Date) -> Bool {
        let date = Date()
        if let hour = date.component(.hour) {
            let start = AntiAddictionKit.configuration.curfewHourStart
            let end = AntiAddictionKit.configuration.curfewHourEnd
            if (start <= hour || hour < end) {
                DebugLog("宵禁时间！")
                return true
            }
        }
        DebugLog("非宵禁时间！")
        return false
    }
    
    /// 距离下一次宵禁的时间间隔( return >= 0)
    class func intervalForNextCurfew() -> Int {
        //晚上22点的时间 = 24点-2小时
        let start: Int = AntiAddictionKit.configuration.curfewHourStart
        let interval: Int = max(Int(Date().dateFor(.endOfDay).timeIntervalSinceNow) - Int(24-start) * 60 * 60, 0)
        return interval
    }
    
    
    /// 是否节假日
    class func isHoliday(_ date: Date) -> Bool {
        // 是否周末
        if date.compare(.isWeekend) {
            return true
        }
        // 是否节日
        let yyyy = date.toString(format: .isoYear)
        let MMdd = date.toString(format: .custom("MMdd"))
        let holiday2020: [String] = ["0101", //元旦1天
                                    "0124", "0125", "0126", "0127", "0128", "0129", "0130", //春节7天
                                    "0404", "0405", "0406", //清明3天
                                    "0501", "0502", "0503", "0504", "0505", //劳动节5天
                                    "0625", "0626", "0627", //端午节 3天
                                    "1001", "1002", "1003", "1004", "1005", "1006", "1007", "1008" //国庆中秋 8天
        ]
        if yyyy == "2020" && holiday2020.contains(MMdd) {
            DebugLog("当前是节日！")
            return true
        }
        
        // 剩余情况
        DebugLog("当前非节日！")
        return false
    }

}
