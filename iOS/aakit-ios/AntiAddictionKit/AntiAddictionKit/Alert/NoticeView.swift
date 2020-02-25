
import UIKit

fileprivate let kNoticeViewHeightDefault: CGFloat = 40
fileprivate let kNoticeLabelEdgeInsets: UIEdgeInsets = edgeInsets(8, 16, 8, 30)

class NoticeViewPresenter: NSObject {
    
    // MARK: - Public
    public class func show(_ attributedText: NSAttributedString) {
        shared.present(attributedText)
    }
    
    public class func hide() {
        shared.dismiss()
    }
    
    
    // MARK: - Private
    private static let shared = NoticeViewPresenter()
    
    private(set) var isPresented: Bool = false

    private let notice = NoticeView()
    
    private var topConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!

    private override init() {
        super.init()
        
        setupNoticeContainer()

        setupNoticeActions()
        
        NotificationCenter.default.addObserver(self, selector: #selector(calculateLayout), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        notice.alpha = 0
    }

    private func present(_ attributedText: NSAttributedString) {
        
        if (self.isPresented) {
            cancelIfDismissing()
        }
        
        notice.titleLabel.attributedText = attributedText
        
        calculateLayout()
        
        if (self.isPresented) { return }
        
        animateIn()
    }

    private func dismiss() {
        animateOut()
    }

    // MARK: - Content
    private func setupNoticeContainer() {
        notice.removeFromSuperview()
        UIApplication.shared.keyWindow?.addSubview(notice)
        notice.superview?.bringSubviewToFront(notice)
    }
    
    private func setupNoticeActions() {
        let tapAuth = UITapGestureRecognizer(target: self, action: #selector(tapToAuth))
        notice.titleLabel.addGestureRecognizer(tapAuth)
        notice.closeButton.addTarget(self, action: #selector(tapToClose), for: .touchUpInside)
    }
    
    @objc func tapToAuth() {
        //如果包含实名登记，则跳实名登记页
        if let attrText = notice.titleLabel.attributedText, (attrText.string.contains("实名登记") || attrText.string.contains("登记实名")) {
            TimeService.stop()
            self.dismiss()
            
            if AntiAddictionKit.configuration.useSdkRealName {
                AntiAddictionKit.sendCallback(result: .gamePause, message: "即将打开实名认证页面")
                Router.openRealNameController(backButtonEnabled: false, forceOpen: true, cancelled: {
                    //右上角有x按钮
                }, succeed: nil)
            } else {
                AntiAddictionKit.sendCallback(result: .realNameRequest, message: "用户支付，请求实名")
            }
            
        }
    }
    
    @objc func tapToClose() {
        //如果是60s倒计时，手动关闭的时候记下
        if let attrText = notice.titleLabel.attributedText, (attrText.string.contains("秒")) {
            AlertTip.userTappedToDismiss = true
        }
        
        self.dismiss()
    }

    private func animateIn() {
        notice.setNeedsLayout()
        self.notice.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.notice.alpha = 1
        }) { (_) in
            self.isPresented = true
        }
    }

    private func animateOut() {
        if notice.alpha == 0 || self.isPresented == false {
            return
        }
        
        notice.alpha = 1

        UIView.animate(withDuration: 0.3, animations: {
            self.notice.alpha = 0
        }) { (_) in
            self.isPresented = false
        }
    }

    @objc
    private func calculateLayout() {
        guard let keyWindow = UIApplication.shared.keyWindow, let attrText = notice.titleLabel.attributedText else {
            return
        }
        let windowWidth = keyWindow.frame.width
        let noticeWidth: CGFloat = isPortrait() ? (windowWidth - 40) : 460
        let calculateTextSize = attrText.boundingRect(with: cgSize(noticeWidth - kNoticeLabelEdgeInsets.left - kNoticeLabelEdgeInsets.right, kNoticeViewHeightDefault), options: .usesLineFragmentOrigin, context: nil).size
        
        let noticeHeight = (calculateTextSize.height + CGFloat(16)) >= kNoticeViewHeightDefault ? calculateTextSize.height + CGFloat(16) : kNoticeViewHeightDefault
        
        let y: CGFloat = isPortrait() ? 89 : 49
        notice.frame = cgRect(CGFloat((windowWidth - noticeWidth)/2), y, noticeWidth, ceil(noticeHeight))
        
        notice.setNeedsLayout()
    }

    private func cancelIfDismissing() {
        notice.layer.removeAllAnimations()
    }
    
    deinit {
        DebugLog("NoticePresenter Deinit")
    }
}


class NoticeView: UIView {
    
    // MARK: - Public
    public func setTitle(_ attributedText: NSAttributedString) {
        titleLabel.attributedText = attributedText
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("✕", for: .normal)
        button.setTitleColor(Appearance.default.iconColor, for: .normal)
        return button
    }()
    
    public var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Private
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabelAndButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabelAndButton()
    }

    private func setupLabelAndButton() {
        backgroundColor = RGBA(0, 0, 0, 0.8)
        clipsToBounds = true
        
        addSubview(titleLabel)
        addSubview(closeButton)
        
        titleLabel.fillSuperView(kNoticeLabelEdgeInsets).forEach { $0.priority = .init(800)}
        closeButton.addCenterYConstraint(toView: self).priority = .init(600)
        closeButton.addRightConstraint(toView: self).priority = .init(600)
        closeButton.addWidthAndHeightConstraint(width: 30, height: 30).forEach { $0.priority = .init(600)}
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        layer.cornerRadius = ceil(frame.height * 10/57)
        layer.cornerRadius = (self.frame.height <= 40) ? self.frame.height/2 : 8
    }
    
    deinit {
        DebugLog("NoticeView Deinit")
    }
}
