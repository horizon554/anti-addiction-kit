
import Foundation
import CommonCrypto


extension String {
    
    
    func encrypt() -> Data? {
        do {
            let aes = try AES(keyString: "FiugQTgPNwCWUY,VhfmM4cKXTLVFvHFe")
            let stringToEncrypt: String = self
            let encryptedData: Data = try aes.encrypt(stringToEncrypt)
            return encryptedData
        } catch {
            return nil
        }
    }
    
    
    
    func isPromoteIDCardNumber() -> Bool {
        
        
        return false
    }
}

class AAKitIDNumberGenerator {
    static let salt: String = "AntiAddictionKit"
    static let `default`: String = "AntiAddictionKit.AAKitIDNumberGenerator.default"
    
    class func generate() -> String {
        let timestamp: Int64 = Int64(Date().timeIntervalSince1970)
//        let timestamp: Int64 = Int64(1234567891)
        let hashid = Hashids(salt: AAKitIDNumberGenerator.salt, minHashLength: 6)
        return hashid.encode(timestamp) ?? self.default
    }
    
    class func isValid(with code: String) -> Bool {
        
        if (code == self.default) { return true }
        
        var realCode: String = code
        
        //防止算法挂了
        let maxLength: Int = 7
        if realCode.count >= maxLength  {
            realCode = String(code.prefix(maxLength))
        }
        
        let timestamp: Int = Int(Date().timeIntervalSince1970)
        let hashid = Hashids(salt: AAKitIDNumberGenerator.salt, minHashLength: 6)
        if let codeTimestamp = hashid.decode(realCode).first {
            return (codeTimestamp < timestamp) && (timestamp <= (codeTimestamp + Int(6 * 3600)))
        } else {
            return false
        }
    }
}
