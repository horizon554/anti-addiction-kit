
import UIKit

extension UIImage {
    /// Creates a `UIImage` object in current framework bundle.
    /// - Parameters:
    ///   - name: The image name.
    ///   - trait: The traits associated with the intended environment for the image.
    convenience init?(bundleNamed name: String, compatibleWith trait: UITraitCollection? = nil) {
        self.init(named: name, in: Bundle.frameworkBundle, compatibleWith: trait)
    }
    
}


extension Bundle {
    
    static let frameworkBundle = Bundle(for: AntiAddictionKit.self)
    
    static let resourceBundle: Bundle = {
        guard let stringPath = Bundle.main.path(forResource: "AntiAddictionKit", ofType: "bundle"), let bundle = Bundle(path: stringPath) else {
            fatalError("缺少资源文件 AntiAddictionKit.bundle")
        }
        
        return bundle
    }()
    
}
