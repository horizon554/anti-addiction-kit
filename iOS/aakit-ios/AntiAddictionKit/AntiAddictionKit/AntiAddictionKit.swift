
import Foundation

/// AAKit 回调协议，回调接收方需遵循此协议。
@objc
public protocol AntiAddictionCallback: class {
    
    /// AAKit 回调方法
    /// - Parameters:
    ///   - code: 回调状态码
    ///   - message: 回调信息
    @objc func onAntiAddictionResult(_ code: Int, _ message: String)
}

@objcMembers
@objc(AntiAddictionKit)
public final class AntiAddictionKit: NSObject {
    
    // MARK: - Public
    
    /// AAKit 配置
    public static var configuration: Configuration = Configuration()
    
    /// AAKit 配置方法
    /// - Parameters:
    ///   - useSdkRealName: 实名登记开关，默认值为 true
    ///   - useSdkPaymentLimit: 支付限制开关，默认值为 true
    ///   - useSdkOnlineTimeLimit: 在线时长限制开关，默认值为 true
    public class func setFunctionConfig(_ useSdkRealName: Bool = true, _ useSdkPaymentLimit: Bool = true, _ useSdkOnlineTimeLimit: Bool = true) {
        configuration.useSdkOnlineTimeLimit = useSdkOnlineTimeLimit
        configuration.useSdkRealName = useSdkRealName
        configuration.useSdkPaymentLimit = useSdkPaymentLimit
    }
    
    /// AAKit 初始化方法
    /// - Parameter delegate: 接受回调的对象
    public class func `init`(_ delegate: AntiAddictionCallback) {
        if (AntiAddictionKit.sharedDelegate != nil) {
            Log("请勿重复初始化！")
        } else {
            AntiAddictionKit.sharedDelegate = delegate
            AntiAddictionKit.addNotificationListener()
            Log("初始化成功！")
        }
    }
    
    /// 登录用户
    /// - Parameters:
    ///   - userId: 用户 id，不能为空
    ///   - userType: 用户类型
    public class func login(_ userId: String, _ userType: Int) {
        if !self.isKitInstalled() { return }
        
        let user = User(id: userId, type: UserType.typeByRawValue(userType))
        UserService.login(user)
    }
    
    /// 更新当前用户信息
    /// - Parameters:
    ///   - userType: 用户类型
    public class func updateUserType( _ userType: Int) {
        if !self.isKitInstalled() { return }
        
        UserService.updateUserType(UserType.typeByRawValue(userType))
    }
    
    /// 退出用户登录
    public class func logout() {
        if !self.isKitInstalled() { return }
        
        UserService.logout()
    }
    
    
    /// 获取用户类型
    /// - Parameter userId: 用户 id
    public class func getUserType(_ userId: String) -> Int {
        if !self.isKitInstalled() { return -1 }
        
        return UserService.getUserType(userId)
    }
    
    
    /// 查询能否支付
    /// - Parameter amount: 支付金额，单位分
    public class func checkPayLimit(_ amount: Int) {
        if !self.isKitInstalled() { return }
        PayService.canPurchase(amount)
    }
    
    /// 设置已支付金额
    /// - Parameter amount: 支付金额，单位分
    public class func paySuccess(_ amount: Int) {
        if !self.isKitInstalled() { return }
        
        PayService.didPurchase(amount)
    }
    
    /// 查询能否支付，直接返回支付限制相关回调类型 raw value
    /// - Parameter amount: 支付金额，单位分
    public class func checkCurrentPayLimit(_ amount: Int) -> Int {
        PayService.checkCurrentPayLimit(amount)
    }
    
    /// 查询当前用户能否聊天
    public class func checkChatLimit() {
        if !self.isKitInstalled() { return }
        
        ChatService.checkChatLimit()
    }
    
    /// 打开实名窗口，实名结果通过回调接受
    public class func openRealName() {
        if !self.isKitInstalled() { return }
        
        RealNameService.openRealname()
    }
    
    // Warning: - DEBUG 模式
    /// 生成身份证兑换码（有效期从生成起6个小时整以内）
    #if DEBUG
    public class func generateIDCode() -> String {
        return AAKitIDNumberGenerator.generate()
    }
    #endif
    
    
    // MARK: - Private
    
    /// 登录用户，当 userId 为空时即退出当前用户
    /// - Parameters:
    ///   - userId: 用户 id
    ///   - userType: 用户类型
//    @available(*, deprecated, message: "use login(), logout() or updateUserType() instead")
//    private class func setUser(_ userId: String, _ userType: Int) {
//        if !self.isKitInstalled() { return }
//
//        if (userId.isEmpty) {
//            UserService.logout()
//        } else {
//            let user = User(id: userId, type: UserType.typeByRawValue(userType))
//            UserService.login(user)
//        }
//    }
    
    
    //禁用初始化方法
    @available(*, unavailable)
    private override init() {
        fatalError("AntiAddictionKit-init is unavailable")
    }
    
}
