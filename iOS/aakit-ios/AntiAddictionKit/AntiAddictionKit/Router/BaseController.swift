
import UIKit

class BaseController: UIViewController {
    
    private var _title: String? = nil
    public override var title: String? {
        get {
            return _title
        }
        set(new) {
            _title = new
            DispatchQueue.main.async {
                self.titleLabel.text = new
            }
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: Appearance.default.titleFontSize)
        label.textColor = Appearance.default.titleTextColor
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = Appearance.default.whiteBackgroundColor

        view.addSubview(titleLabel)
        titleLabel.addCenterXConstraint(toView: view)
        titleLabel.addTopConstraint(toView: view, constant: 14)
        titleLabel.addWidthConstraint(constant: 120)
        titleLabel.addHeightConstraint(constant: 22)
    }
}
