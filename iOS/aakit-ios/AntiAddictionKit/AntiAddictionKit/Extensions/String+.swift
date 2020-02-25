
import Foundation

func getStringByRange(_ aString: String, location: Int, length: Int) -> String {
    let startIndex = aString.index(aString.startIndex, offsetBy: location)
    let endIndex = aString.index(aString.startIndex, offsetBy: location)
    return String(aString[startIndex...endIndex])
}

func getStringIntValueByRange(_ aString: String, location: Int, length: Int) -> Int {
    let startIndex = aString.index(aString.startIndex, offsetBy: location)
    let endIndex = aString.index(aString.startIndex, offsetBy: location)
    let subStr = aString[startIndex...endIndex]
    return Int(String(subStr)) ?? -1
}

extension String {
    func fullRange() -> NSRange {
        return NSRange(location: 0, length: self.count)
    }
}

extension String {
    
    /// 验证真实姓名（目前仅判断长度>0）
    func isValidRealName() -> Bool {
        if self.count <= 1 {
            return false
        }
        
//        let simplifiedChinese = 0x4E00...0x9FFF
//        
//        for chr in self.unicodeScalars {
//            let value = chr.value
//            if value < simplifiedChinese.startIndex || value > simplifiedChinese.endIndex {
//                return false
//            }
//        }
        
        return true
    }
    
    /// 验证邮箱
    func isValidEmail() -> Bool {
        if self.count == 0 {
            return false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    /// 验证 15/18 位身份证号
    func isValidIDCardNumber() -> Bool {

        var value = self
        value = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let length = value.count
        
        // 检查位数
        if length != 15 && length != 18{
            return false
        }
        
        // 检查前缀 2 位数字是否为省份代码
        // 省份代码
        let areasArray = ["11","12", "13","14", "15","21", "22","23", "31","32", "33","34", "35","36", "37","41", "42","43", "44","45", "46","50", "51","52", "53","54", "61","62", "63","64", "65","71", "81","82", "91"]
        let valueStart2 = value.prefix(2)
        var areaFlag = false
        for areaCode in areasArray {
            if areaCode == valueStart2 {
                areaFlag = true
                break
            }
        }
        if !areaFlag {
            return false
        }
        
        var regularExpression: NSRegularExpression
        var numberofMatch : Int = 0
        
        if length == 15 {
            let yearStart = value.index(value.startIndex, offsetBy: 6)
            let yearEnd = value.index(value.startIndex, offsetBy: 8)
            let yearString = value[yearStart...yearEnd]
            guard let yearStringInt = Int(yearString) else { return false }
            let year = yearStringInt + 1900
            if year % 4 == 0 || (year % 100 == 0 && year % 4 == 0) {
                //创建正则表达式
                do {
                    regularExpression = try NSRegularExpression.init(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$", options: .caseInsensitive)
                } catch {
                    return false
                }
            } else {
                do {
                    regularExpression = try NSRegularExpression.init(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$", options: .caseInsensitive)
                } catch {
                    return false
                }
            }
            //测试出生日期的合法性
            numberofMatch = regularExpression.numberOfMatches(in: value, options: NSRegularExpression.MatchingOptions.reportProgress, range: value.fullRange())
            if numberofMatch > 0 {
                return true
            } else{
                return false
            }
        }
        else if length == 18 {
            let yearStart = value.index(value.startIndex, offsetBy: 6)
            let yearEnd = value.index(value.startIndex, offsetBy: 10)
            let yearString = value[yearStart...yearEnd]
            guard let year = Int(yearString) else { return false }
            if year % 4 == 0 || (year % 100 == 0 && year % 4 == 0) {
                do {
                    regularExpression = try NSRegularExpression.init(pattern: "^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}(((19|20)\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|((19|20)\\d{2}(0[13578]|1[02])31)|((19|20)\\d{2}02(0[1-9]|1\\d|2[0-8]))|((19|20)([13579][26]|[2468][048]|0[048])0229))\\d{3}(\\d|X|x)?$", options: .caseInsensitive)
                } catch {
                    return false
                }
            } else {
                do {
                    regularExpression = try NSRegularExpression.init(pattern: "^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}(((19|20)\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|((19|20)\\d{2}(0[13578]|1[02])31)|((19|20)\\d{2}02(0[1-9]|1\\d|2[0-8]))|((19|20)([13579][26]|[2468][048]|0[048])0229))\\d{3}(\\d|X|x)?$", options: .caseInsensitive)
                } catch {
                    return false
                }
            }
            //测试出生日期的合法性
            numberofMatch = regularExpression.numberOfMatches(in: value, options: NSRegularExpression.MatchingOptions.reportProgress, range: value.fullRange())
            
            if numberofMatch > 0 {
                // 1：校验码的计算方法 身份证号码17位数分别乘以不同的系数。从第一位到第十七位的系数分别为：7－9－10－5－8－4－2－1－6－3－7－9－10－5－8－4－2。将这17位数字和系数相乘的结果相加。
                let a = getStringIntValueByRange(value, location: 0, length: 1) * 7
                let b = getStringIntValueByRange(value, location: 10, length: 1) * 7
                let c = getStringIntValueByRange(value, location: 1, length: 1) * 9
                let d = getStringIntValueByRange(value, location: 11, length: 1) * 9
                let e = getStringIntValueByRange(value, location: 2, length: 1) * 10
                let f = getStringIntValueByRange(value, location: 12, length: 1) * 10
                let g = getStringIntValueByRange(value, location: 3, length: 1) * 5
                let h = getStringIntValueByRange(value, location: 13, length: 1) * 5
                let i = getStringIntValueByRange(value, location: 4, length: 1) * 8
                let j = getStringIntValueByRange(value, location: 14, length: 1) * 8
                let k = getStringIntValueByRange(value, location: 5, length: 1) * 4
                let l = getStringIntValueByRange(value, location: 15, length: 1) * 4
                let m = getStringIntValueByRange(value, location: 6, length: 1) * 2
                let n = getStringIntValueByRange(value, location: 16, length: 1) * 2
                let o = getStringIntValueByRange(value, location: 7, length: 1) * 1
                let p = getStringIntValueByRange(value, location: 8, length: 1) * 6
                let q = getStringIntValueByRange(value, location: 9, length: 1) * 3
                
                // 2：用加出来和除以11，看余数是多少？余数只可能有0－1－2－3－4－5－6－7－8－9－10这11个数字
                let S = a + b + c + d + e + f + g + h + i + j + k + l + m + n + o + p + q
                
                let Y = S % 11
                
                var M = "F"
                
                let JYM: String = "10X98765432"
                
                // 3：获取校验位
                M = getStringByRange(JYM, location: Y, length: 1)
                
                //4：对比给定字符串的最后一位
                let lastStr = getStringByRange(value, location: 17, length: 1)
                
                if lastStr == "x" {
                    return M == "X"
                } else {
                    return M == lastStr
                }
                
            } else {
                return false
            }

            
        }

        
        return false
    }

    
    /// 验证 11 位手机号 1xx xxxx xxxx
    func isValidPhoneNumber() -> Bool {
        let phone = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if phone.count == 11 && String(phone.prefix(1)) == "1" {
            return true
        }
        return false
    }
    
    
}


/// 年龄相关
extension String {
    /// 从身份证中拿出日期 yyyyMMdd 20200101
    func yyyyMMdd() -> String? {
        if (count != 15 && count != 18) {
            return nil
        }
        
        if (count == 15) {
            let dateStart = index(startIndex, offsetBy: 6)
            let dateEnd = index(startIndex, offsetBy: 13)
            let date = "19" + String(self[dateStart...dateEnd])
            return (date.count == 8 ? date : nil)
        }
        
        if (count == 18) {
            let dateStart = index(startIndex, offsetBy: 6)
            let dateEnd = index(startIndex, offsetBy: 13)
            let date = String(self[dateStart...dateEnd])
            return (date.count == 8 ? date : nil)
        }
        
        return nil
    }
}
