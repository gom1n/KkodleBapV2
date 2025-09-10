//
//  MenuAlertViewController.swift
//  KkodleBap
//
//  Created by gomin on 9/10/25.
//

import UIKit
import SnapKit
import Then

public final class MenuAlertViewController: UIViewController {
    
    // UI
    fileprivate let dimView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.alpha = 0
    }
    fileprivate let container = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
        $0.alpha = 0
        $0.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
    }
    private let vStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
        $0.alignment = .fill
        $0.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    private let closeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .secondaryLabel
    }
    
    // Config
    private var handlers: [Int: () -> Void] = [:]
    private var actionIndex = 0
    
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
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(dimView)
        view.addSubview(container)
        container.addSubview(vStack)
        container.addSubview(closeButton)
        
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(vStack).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        dimView.addGestureRecognizer(tap)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }
    
    // MARK: - Public APIs
    
    public func setTitle(_ title: String) {
        let label = UILabel().then {
            $0.text = title
            $0.font = .preferredFont(forTextStyle: .headline)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        vStack.addArrangedSubview(label)
    }
    
    public func addMenuItem(title: String, handler: (() -> Void)? = nil) {
        let idx = actionIndex
        actionIndex += 1
        
        let button = UIButton(type: .system).then {
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
            $0.contentHorizontalAlignment = .center
            $0.backgroundColor = .gray_0
            $0.layer.borderColor = UIColor.blue_6.cgColor
            $0.layer.borderWidth = 1
            $0.setTitleColor(.blue_6, for: .normal)
            $0.tag = idx
            $0.titleLabel?.numberOfLines = 0
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.contentEdgeInsets = UIEdgeInsets(top: 14, left: 8, bottom: 14, right: 8)
        }
        button.addTarget(self, action: #selector(didTapMenu(_:)), for: .touchUpInside)
        
        vStack.addArrangedSubview(button)
        vStack.setCustomSpacing(12, after: button)
        handlers[idx] = handler
    }
    
    // MARK: - Actions
    
    @objc private func didTapOutside() {
        dismiss(animated: true)
    }
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    @objc private func didTapMenu(_ sender: UIButton) {
        dismiss(animated: true) {
            self.handlers[sender.tag]?()
        }
    }
}

// MARK: - Transitioning
extension MenuAlertViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuAlertAnimator(presenting: true)
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuAlertAnimator(presenting: false)
    }
}

final class MenuAlertAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let presenting: Bool
    init(presenting: Bool) { self.presenting = presenting }
    
    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval { 0.35 }
    
    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let container = ctx.containerView
        
        if presenting {
            guard let toVC = ctx.viewController(forKey: .to) as? MenuAlertViewController else { return }
            container.addSubview(toVC.view)
            toVC.view.frame = container.bounds
            
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
            guard let fromVC = ctx.viewController(forKey: .from) as? MenuAlertViewController else { return }
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
