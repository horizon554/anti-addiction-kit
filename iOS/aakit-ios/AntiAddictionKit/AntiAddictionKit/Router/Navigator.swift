
import UIKit

class Navigator: UINavigationController {
    
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        navigationBar.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performTransformScale()
    }
    
    private func performTransformScale() {
        view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.transform = CGAffineTransform(scaleX: kContainerScale, y: kContainerScale)
    }
    
}
