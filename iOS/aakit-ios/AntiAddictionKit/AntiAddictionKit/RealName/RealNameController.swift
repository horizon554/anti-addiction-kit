
import UIKit

class RealNameController: BaseController {
    
    // MARK: - Public
    public convenience init(backButtonEnabled flag: Bool, cancelled: (() -> Void)? = nil, succeed: (() -> Void)? = nil) {
        self.init()
        self.backButtonEnabled = flag
        
        self.realnameCancelledClosure = cancelled
        self.realnameSucceedClosure = succeed
    }
    
    private var backButtonEnabled: Bool = false
    
    private var realnameCancelledClosure: (() -> Void)?
    private var realnameSucceedClosure: (() -> Void)?
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Private
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .clear
        b.tintColor = Appearance.default.iconColor
        b.setImage(UIImage(bundleNamed: "btn_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .clear
        b.tintColor = Appearance.default.iconColor
        b.setImage(UIImage(bundleNamed: "btn_close")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var submitButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = Appearance.default.blackBackgroundColor
        b.setTitle("提交", for: .normal)
        b.setTitleColor(Appearance.default.whiteBackgroundColor, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: Appearance.default.bodyFontSize)
        b.clipsToBounds = true
        b.layer.cornerRadius = 16
        b.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var tipButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .clear
        b.setTitle("关于实名登记", for: .normal)
        b.tintColor = Appearance.default.iconColor
        b.setImage(UIImage(bundleNamed: "btn_auth_tip")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.titleEdgeInsets = edgeInsets(0, 5, 0, 0)
        b.setTitleColor(Appearance.default.placeholderColor, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: Appearance.default.tipFontSize)
        b.addTarget(self, action: #selector(tipButtonTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var nameTextField: AATextField = {
        let tf = AATextField()
        tf.attributedPlaceholder = self.attributedPlaceholder("真实姓名")
        tf.keyboardType = .default
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .none;
        tf.font = UIFont.systemFont(ofSize: Appearance.default.bodyFontSize)
        tf.textColor = Appearance.default.titleTextColor
        tf.delegate = self
        return tf
    }()
    
    private lazy var idCardTextField: AATextField = {
        let tf = AATextField()
        tf.attributedPlaceholder = self.attributedPlaceholder("身份证")
        tf.keyboardType = .asciiCapable
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .none;
        tf.font = UIFont.systemFont(ofSize: Appearance.default.bodyFontSize)
        tf.textColor = Appearance.default.titleTextColor
        tf.delegate = self
        return tf
    }()
    
    private lazy var phoneTextField: AATextField = {
        let tf = AATextField()
        tf.attributedPlaceholder = self.attributedPlaceholder("手机号")
        tf.keyboardType = .numberPad
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .none;
        tf.font = UIFont.systemFont(ofSize: Appearance.default.bodyFontSize)
        tf.textColor = Appearance.default.titleTextColor
        tf.delegate = self
        return tf
    }()
    
    private lazy var tipButtonPositionXConstraint: NSLayoutConstraint? = nil
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TimeService.stop()
        
        title = "游戏实名登记"
        
        view.addSubview(backButton)
        view.addSubview(closeButton)
        view.addSubview(submitButton)
        view.addSubview(tipButton)
        view.addSubview(nameTextField)
        view.addSubview(idCardTextField)
        view.addSubview(phoneTextField)
        
        updateSubviewLayout()
    }
    
    private func updateSubviewLayout() {
        
        backButton.isHidden = !self.backButtonEnabled
        closeButton.isHidden = (self.realnameCancelledClosure == nil)
        
        backButton.addLeftConstraint(toView: view)
        backButton.addTopConstraint(toView: view)
        backButton.addWidthAndHeightConstraint(width: 30, height: 30)
        
        closeButton.addRightConstraint(toView: view)
        closeButton.addTopConstraint(toView: view)
        closeButton.addWidthAndHeightConstraint(width: 30, height: 30)
        
        submitButton.addBottomConstraint(toView: view, constant: -54)
        submitButton.addCenterXConstraint(toView: view)
        submitButton.addWidthAndHeightConstraint(width: 210, height: 32)
        
        tipButton.addBottomConstraint(toView: view, constant: -10)
        tipButton.addWidthAndHeightConstraint(width: 100, height: 18)
        tipButtonPositionXConstraint = tipButton.addLeftConstraint(toView: view, constant: isLandscape() ? 10 : (95))
        
        phoneTextField.addCenterXConstraint(toView: view)
        phoneTextField.addBottomConstraint(toView: view, constant: -110)
        phoneTextField.addWidthAndHeightConstraint(width: 225, height: 32)

        idCardTextField.addCenterXConstraint(toView: view)
        idCardTextField.addBottomConstraint(toView: view, constant: -150)
        idCardTextField.addWidthAndHeightConstraint(width: 225, height: 32)

        nameTextField.addCenterXConstraint(toView: view)
        nameTextField.addBottomConstraint(toView: view, constant: -190)
        nameTextField.addWidthAndHeightConstraint(width: 225, height: 32)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if let c = tipButtonPositionXConstraint {
            c.constant = isLandscape() ? 10 : (95)
        }
        
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
}

extension RealNameController {
    private func attributedPlaceholder(_ placeholder: String) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(string: placeholder)
        attrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: Appearance.default.bodyFontSize), range: placeholder.fullRange())
        attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: Appearance.default.placeholderColor, range: placeholder.fullRange())
        return attrStr
    }
}


extension RealNameController {
    
    @objc func tipButtonTapped() {
        AuthTip.show(to: self.tipButton)
    }
    
    @objc func backButtonTapped() {
        AuthTip.hide()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func closeButtonTapped() {
        AuthTip.hide()
        
        Router.closeContainer()
        
        AntiAddictionKit.sendCallback(result: .realNameAuthFailed, message: "用户实名登记失败！")
        
        realnameCancelledClosure?()
        
        TimeService.start()
    }
    
    
    @objc func submitButtonTapped() {
        AuthTip.hide()
        
        let name = nameTextField.text ?? ""
        let idCard = idCardTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        
        if (name.isValidRealName() == false) {
            makeToast("请填写真实姓名")
            return
        }
        
        let isRealIDCardNumber = idCard.isValidIDCardNumber()
        let isGeneratedCode = AAKitIDNumberGenerator.isValid(with: idCard)
        if (isRealIDCardNumber == false && isGeneratedCode == false) {
            makeToast("请填写有效身份证号")
            return
        }
        
        if (phone.isValidPhoneNumber() == false) {
            makeToast("请填写有效手机号")
            return
        }
        
        
        
        view.makeToastActivity(.center)

        if let _ = User.shared {
            
            //根据身份证生日更新用户信息
            if let yearStr = idCard.yyyyMMdd() {
                let age = DateHelper.getAge(yearStr)
                
                if age < 0 {
                    authFailed()
                    return
                }
                //登记成功
                
                let type = UserType.typeByAge(age)
                
                User.shared?.updateUserType(type)
                User.shared?.updateUserRealName(name: name.encrypt(),
                                                idCardNumber: idCard.encrypt(),
                                                phone: phone.encrypt())
                
                authSucceed()
                
                return
                
            } else {
                //判断身份证是不是兑换码
                if isGeneratedCode {
                    //如果兑换码有效,更新用户为成人
                    User.shared?.updateUserType(.adult)
                    
                    authSucceed()
                    
                    return
                    
                } else {
                    //兑换码无效
                    authFailed()
                    return
                }
            }
            
        } else {
            authFailed()
            return
        }
        
    }
    
    /// 实名登记成功
    private func authSucceed() {
        DispatchQueue.main.asyncAfter(deadline: 0.3) {
            self.view.hideToastActivity()
            self.makeToast("实名登记成功")
            
            Router.closeAlertTip()
            Router.closeContainer()
            
            AntiAddictionKit.sendCallback(result: .realNameAuthSucceed, message: "用户实名登记成功！")
            
            self.realnameSucceedClosure?()
            
            TimeService.start()
        }
    }
    
    /// 实名登记失败
    private func authFailed() {
        self.view.hideToastActivity()
        makeToast("实名登记失败")
    }
    
    
    private func makeToast(_ message: String) {
        view.makeToast(message, duration: 1.0, position: .center)
    }
}

extension RealNameController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateContent(-90)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //禁止输入空格和换行
        let validString = string.components(separatedBy: .whitespacesAndNewlines).joined()
        return validString == string
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == nameTextField) {
            idCardTextField.becomeFirstResponder()
        } else if (textField == idCardTextField) {
            phoneTextField.becomeFirstResponder()
        } else if (textField == phoneTextField) {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateContent(.zero)
    }
    
    func animateContent(_ offsetY: CGFloat) {
        //隐藏实名tipView
        AuthTip.hide()
        
        guard let navigatorView = navigationController?.view else { return }
        guard let containerView = navigatorView.superview else { return }
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseOut, animations: {
            for c in containerView.constraints {
                if (c.firstAttribute == c.secondAttribute && c.firstAttribute == .centerY) {
                    c.constant = offsetY;
                }
            }
            containerView.layoutIfNeeded()
        }) { (_) in
            
        }
    }
}
