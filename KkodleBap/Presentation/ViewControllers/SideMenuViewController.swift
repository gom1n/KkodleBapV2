//
//  SideMenuViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/26/25.
//

import UIKit
import SnapKit
import Then

final class SideMenuViewController: UIViewController {
    var onTapMap: (() -> Void)?
    var onTapHistory: (() -> Void)?

    private let dimView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        $0.alpha = 0
    }
    private let panel = UIView().then {
        $0.backgroundColor = .gray_0
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowRadius = 12
    }
    
    private let menuTitle = UILabel().then {
        $0.text = "메뉴"
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .secondaryLabel
    }
    
    private let stack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        $0.isLayoutMarginsRelativeArrangement = true
    }

    private lazy var mapButton = makeItem(title: "맵 보기", systemName: "map")
    private lazy var historyButton = makeItem(title: "히스토리 보기", systemName: "clock.arrow.circlepath")

    private var panelLeading: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        view.addSubview(dimView)
        view.addSubview(panel)
        panel.addSubview(menuTitle)
        panel.addSubview(stack)
        
        [mapButton, historyButton].forEach { stack.addArrangedSubview($0) }

        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }
        panel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            panelLeading = make.leading.equalTo(view.snp.leading).offset(-UIScreen.main.bounds.width * 0.5).constraint
        }
        
        menuTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
        }
        stack.snp.makeConstraints {
            $0.top.equalTo(menuTitle.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        dimView.addGestureRecognizer(tap)

        mapButton.addTarget(self, action: #selector(tapMap), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(tapHistory), for: .touchUpInside)
    }

    private func makeItem(title: String, systemName: String) -> UIButton {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.plain()
        cfg.baseForegroundColor = .label
        cfg.attributedTitle = .init(title, attributes: .init([.font: UIFont.systemFont(ofSize: 18, weight: .regular)]))
        b.configuration = cfg
        b.contentHorizontalAlignment = .leading
        b.heightAnchor.constraint(equalToConstant: 22).isActive = true
        b.backgroundColor = .clear
        return b
    }

    // MARK: Present/Dismiss (Child VC 방식)
    func present(from parent: UIViewController) {
        parent.addChild(self)
        parent.view.addSubview(view)
        view.snp.makeConstraints { $0.edges.equalTo(parent.view) }
        didMove(toParent: parent)

        // 애니메이션: dim 알파, 패널 슬라이드 인
        parent.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.dimView.alpha = 1
            self.panelLeading?.update(offset: 0)
            parent.view.layoutIfNeeded()
        }
    }

    @objc func dismissSelf() {
        guard let parent = parent else { return }
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseIn) {
            self.dimView.alpha = 0
            self.panelLeading?.update(offset: -parent.view.bounds.width * 0.5)
            parent.view.layoutIfNeeded()
        } completion: { _ in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

    // MARK: Actions
    @objc private func tapMap() {
        dismissSelf()
        onTapMap?()
    }
    @objc private func tapHistory() {
        dismissSelf()
        onTapHistory?()
    }
}
