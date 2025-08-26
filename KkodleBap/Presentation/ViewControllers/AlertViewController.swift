//
//  AlertViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/21/25.
//

import UIKit
import SnapKit
import Then


// MARK: - Action
public struct KoodleAlertAction {
    public enum Style { case primary, secondary, destructive }
    public let title: String
    public let style: Style
    public let handler: (() -> Void)?
    public init(_ title: String, style: Style = .primary, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

// MARK: - ViewController
public final class KoodleAlertViewController: UIViewController {

    // UI
    public let dimView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.alpha = 0
    }
    public let container = UIView().then {
        $0.backgroundColor = .gray_0
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
        $0.alpha = 0
        $0.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
    }
    private let vStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 16, right: 20)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    private let buttonArea = UIStackView().then {
        $0.spacing = 8
        $0.distribution = .fillEqually
        $0.axis = .horizontal
    }
    
    // Config
    private var actions: [KoodleAlertAction] = []
    private var handlers: [Int: () -> Void] = [:]

    // Init
    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        self.setupViews()
    }
    
    private func setupViews() {
        view.addSubview(dimView)
        view.addSubview(container)
        container.addSubview(vStack)
        
        dimView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        vStack.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        dimView.addGestureRecognizer(tap)
    }
    
    public func setTitle(_ title: String?) {
        // Title
        if let title = title, !title.isEmpty {
            let titleLabel = UILabel().then {
                $0.text = title
                $0.font = .preferredFont(forTextStyle: .headline)
                $0.numberOfLines = 0
                $0.textAlignment = .center
            }
            vStack.addArrangedSubview(titleLabel)
        }
    }
    
    public func setAnswerTitle(_ answer: String) {
        let titleLabel = UILabel().then {
            $0.text = "정답은 \(answer)입니다."
            $0.font = .preferredFont(forTextStyle: .headline)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        vStack.addArrangedSubview(titleLabel)
    }
    
    public func setMessage(_ message: String?) {
        // Message
        if let msg = message, !msg.isEmpty {
            let messageLabel = UILabel().then {
                $0.text = msg
                $0.font = .preferredFont(forTextStyle: .subheadline)
                $0.textColor = .secondaryLabel
                $0.numberOfLines = 0
                $0.textAlignment = .center
            }
            vStack.addArrangedSubview(messageLabel)
        }
    }
    
    public func addCustomView(_ customView: UIView) {
        vStack.addArrangedSubview(customView)
    }
    
    public func addButtons(_ actions: [KoodleAlertAction]) {
        ensureButtonAreaInserted()
        
        for action in actions {
            let idx = actions.count              // 고유 인덱스
            self.actions.append(action)
            let btn = makeButton(for: action, tag: idx)
            handlers[idx] = action.handler ?? {} // nil이면 빈 클로저
            buttonArea.addArrangedSubview(btn)
        }
    }
    
    public func addButton(_ action: KoodleAlertAction) {
        ensureButtonAreaInserted()
        
        let idx = actions.count
        actions.append(action)
        let btn = makeButton(for: action, tag: idx)
        handlers[idx] = action.handler ?? {}
        buttonArea.addArrangedSubview(btn)
    }
    
    /// 버튼 영역 존재 여부 확인 뒤 추가
    private func ensureButtonAreaInserted() {
        if !vStack.arrangedSubviews.contains(buttonArea) {
            vStack.addArrangedSubview(buttonArea)
        }
    }

    private func makeButton(for action: KoodleAlertAction, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(action.title, for: .normal)
        btn.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        btn.titleLabel?.numberOfLines = 0
        btn.layer.cornerRadius = 8
        btn.clipsToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 14, left: 8, bottom: 14, right: 8)
        styleButton(btn, style: action.style)
        btn.tag = tag
        btn.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
        return btn
    }

    private func styleButton(_ btn: UIButton, style: KoodleAlertAction.Style) {
        switch style {
        case .primary:
            btn.backgroundColor = .blue_5
            btn.layer.borderColor = UIColor.clear.cgColor
            btn.layer.borderWidth = 0
            btn.setTitleColor(.gray_0, for: .normal)
        case .secondary:
            btn.backgroundColor = .gray_0
            btn.layer.borderColor = UIColor.blue_5.cgColor
            btn.layer.borderWidth = 1
            btn.setTitleColor(.blue_5, for: .normal)
        case .destructive:
            btn.backgroundColor = .gray_1
            btn.layer.borderColor = UIColor.clear.cgColor
            btn.layer.borderWidth = 0
            btn.setTitleColor(.gray_2, for: .normal)
        }
        // 배경은 시스템 스타일 유지 (iOS 15+에서는 UIButton.Configuration 사용 가능)
    }

    private func actionHash(_ a: KoodleAlertAction) -> Int {
        return a.title.hashValue ^ (a.style.hashValue << 2)
    }

    @objc private func tapButton(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if let handler = handlers[sender.tag] {
            handler()
        }
    }

    @objc private func didTapOutside() {
        // 필요 시 바깥 탭으로 닫기 허용/비허용 토글 가능
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Transitioning
extension KoodleAlertViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return KoodleAlertAnimator(presenting: true)
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return KoodleAlertAnimator(presenting: false)
    }
}

final class KoodleAlertAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    init(presenting: Bool) { self.presenting = presenting }

    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval { 0.35 }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let container = ctx.containerView

        if presenting {
            guard let toVC = ctx.viewController(forKey: .to) as? KoodleAlertViewController else { return }
            container.addSubview(toVC.view)
            toVC.view.frame = container.bounds
            // 초기 상태는 viewDidLoad에서 설정됨(dim=0, container alpha/scale)

            UIView.animate(withDuration: 0.35,
                           delay: 0,
                           usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.6,
                           options: [.curveEaseOut]) {
                toVC.dimView.alpha = 1
                toVC.container.alpha = 1
                toVC.container.transform = .identity
            } completion: { _ in
                ctx.completeTransition(true)
            }
        } else {
            guard let fromVC = ctx.viewController(forKey: .from) as? KoodleAlertViewController else { return }
            UIView.animate(withDuration: 0.22, animations: {
                fromVC.dimView.alpha = 0
                fromVC.container.alpha = 0
                fromVC.container.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            }, completion: { _ in
                ctx.completeTransition(true)
            })
        }
    }
}
