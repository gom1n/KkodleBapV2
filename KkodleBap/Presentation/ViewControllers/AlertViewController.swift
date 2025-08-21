//
//  AlertViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/21/25.
//

import UIKit
import SnapKit
import Then

import UIKit

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

    // Config
    private let alertTitle: String?
    private let message: String?
    private let customViews: [UIView]
    private let actions: [KoodleAlertAction]

    // UI
    public let dimView = UIView()
    public let container = UIView()
    private let vStack = UIStackView()
    private let buttonArea = UIStackView()

    // Init
    public init(title: String?,
                message: String?,
                customViews: [UIView] = [],
                actions: [KoodleAlertAction]) {
        self.alertTitle = title
        self.message = message
        self.customViews = customViews
        self.actions = Array(actions.prefix(2)) // 1~2개만
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Dim
        view.backgroundColor = .clear
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        dimView.alpha = 0
        view.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        dimView.addGestureRecognizer(tap)

        // Container
        container.backgroundColor = .gray_0
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        container.alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)

        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            container.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            container.widthAnchor.constraint(lessThanOrEqualToConstant: 340)
        ])

        // Vertical stack (content)
        vStack.axis = .vertical
        vStack.spacing = 12
        vStack.alignment = .fill
        vStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 16, right: 20)
        vStack.isLayoutMarginsRelativeArrangement = true
        container.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: container.topAnchor),
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        // Title
        if let title = alertTitle, !title.isEmpty {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .preferredFont(forTextStyle: .headline)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            vStack.addArrangedSubview(titleLabel)
        }

        // Message
        if let msg = message, !msg.isEmpty {
            let messageLabel = UILabel()
            messageLabel.text = msg
            messageLabel.font = .preferredFont(forTextStyle: .subheadline)
            messageLabel.textColor = .secondaryLabel
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            vStack.addArrangedSubview(messageLabel)
        }

        // Custom arranged subviews
        for cv in customViews {
            vStack.addArrangedSubview(cv)
        }

        // Buttons area
        buttonArea.axis = (actions.count == 2) ? .horizontal : .vertical
        buttonArea.spacing = 8
        buttonArea.distribution = .fillEqually
        let topSeparator = UIView()
        topSeparator.backgroundColor = .clear
        topSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        vStack.addArrangedSubview(topSeparator)
        vStack.addArrangedSubview(buttonArea)

        // Buttons
        for (idx, action) in actions.enumerated() {
            let btn = makeButton(for: action)
            buttonArea.addArrangedSubview(btn)

            if actions.count == 2 && idx == 0 {
                // vertical separator for two buttons
                let sep = UIView()
                sep.backgroundColor = .clear
                sep.translatesAutoresizingMaskIntoConstraints = false
                buttonArea.addSubview(sep)
                NSLayoutConstraint.activate([
                    sep.widthAnchor.constraint(equalToConstant: 0.5),
                    sep.topAnchor.constraint(equalTo: buttonArea.topAnchor),
                    sep.bottomAnchor.constraint(equalTo: buttonArea.bottomAnchor),
                    sep.centerXAnchor.constraint(equalTo: buttonArea.centerXAnchor)
                ])
            }
        }

        // Bottom constraint to container
        let bottom = vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        bottom.priority = .required
        bottom.isActive = true
    }

    private func makeButton(for action: KoodleAlertAction) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(action.title, for: .normal)
        btn.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        btn.layer.cornerRadius = 8
        btn.clipsToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 14, left: 8, bottom: 14, right: 8)
        btn.tag = actionHash(action)
        styleButton(btn, style: action.style)
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
        // 어떤 버튼인지 찾기
        if let action = actions.first(where: { actionHash($0) == sender.tag }) {
            dismiss(animated: true) { action.handler?() }
        } else {
            dismiss(animated: true, completion: nil)
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
