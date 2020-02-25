
import Foundation

enum UserType: Int, Codable {
    case unknown = 0 // 未知（未实名）
    case child = 1 // 0-7岁
    case junior = 2 // 8-15岁
    case senior = 3  // 16-17岁
    case adult = 4// 18岁+
    
    static func typeByAge(_ age: Int) -> UserType {
        switch age {
        case 0...7: return .child
        case 8...15: return .junior
        case 16...17: return .senior
        case 18...Int.max: return .adult
        default: return .unknown
        }
    }
    
    static func typeByRawValue(_ rawValue: Int) -> UserType {
        switch rawValue {
        case UserType.unknown.rawValue: return UserType.unknown
        case UserType.child.rawValue: return UserType.child
        case UserType.junior.rawValue: return UserType.junior
        case UserType.senior.rawValue: return UserType.senior
        case UserType.adult.rawValue: return UserType.adult
        default: return UserType.unknown
        }
    }
}

extension User {
    
    private static var privateShared: User? = nil
    
    static var shared: User? {
        get {
            return privateShared
        }
        set(new) {
            privateShared = new
        }
    }
    
}

extension User {
    
    /// 传入一个相同 id 的 user 以更新自身状态
    /// - Parameter new: new.id == self.id
    mutating func update(with new: User) {
        //如果id不同，无法更新
        if (new.id != self.id) {
            DebugLog("user.id 不同，无法更新")
            return
        }
        
        self.updateUserType(new.type)
    }
    
    mutating func updateUserType(_ type: UserType) {
        if (type == .unknown && self.type != .unknown && AntiAddictionKit.configuration.useSdkRealName) {
            DebugLog("UserType 异常，无需更新")
            return
        }
        
        if (type == self.type) {
            DebugLog("UserType 相同，无需更新")
            return
        }
        
        self.resetUserInfoButId()
        
        self.type = type
        DebugLog("当前用户类型已更新！")
    }
    
    mutating func updateUserRealName(name: Data?, idCardNumber: Data?, phone: Data?) {
        self.realName = name
        self.idCardNumber = idCardNumber
        self.phone = phone
        DebugLog("当前用户实名信息已更新！")
    }
     
    mutating func resetOnlineTime(_ time: Int) {
        self.totalOnlineTime = time
        DebugLog("当前用户游戏时长已重设！")
    }
    
    mutating func onlineTimeIncrease(_ addition: Int) {
        self.totalOnlineTime += addition
        DebugLog("当前用户游戏时长已增加！")
        
        UserService.store(self)
    }
    
    mutating func clearOnlineTime() {
        self.totalOnlineTime = 0
        DebugLog("当前用户游戏时长已清空！")
    }
    
    mutating func paymentIncrease(_ addition: Int) {
        self.totalPaymentAmount += addition
        DebugLog("当前用户月总支付金额已增加！")
    }
    
    mutating func clearPaymentAmount() {
        self.totalPaymentAmount = 0
        DebugLog("当前用户月总支付金额已清空！")
    }
    
    mutating func updateTimestamp() {
        self.timestamp = Date()
        DebugLog("当前用户时间戳已更新！")
    }
    
    mutating private func resetUserInfoButId() {
        self.type = .unknown
        self.age = -1
        self.idCardNumber = nil
        self.realName = nil
        self.phone = nil
        self.totalOnlineTime = 0
        self.totalPaymentAmount = 0
        self.timestamp = Date()
    }
}


extension User {
    init() {
        self.id = ""
        self.type = .unknown

        self.age = -1

        self.idCardNumber = nil
        self.realName = nil
        self.phone = nil

        self.totalOnlineTime = 0
        self.totalPaymentAmount = 0

        self.timestamp = Date()
    }
    
    init(id: String, type: UserType = .unknown) {
        self.init()
        
        self.id = id
        self.type = type
    }
    
//    init(id: String, type: UserType, age: Int, idCardNumber: String, realName: String, phone: String, totalPlayDuration: Int, totalPaymentAmount: Int, timestamp: Date) {
//        self.init()
//
//        self.id = id
//        self.type = type
//
//        self.age = age
//
//        self.idCardNumber = idCardNumber
//        self.realName = realName
//        self.phone = phone
//
//        self.totalPlayDuration = 0
//        self.totalPaymentAmount = 0
//
//        self.timestamp = timestamp
//    }
}
