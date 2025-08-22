//
//  KeyboardView.swift
//  KkodleBap
//
//  Created by gomin on 8/7/25.
//


import UIKit
import SnapKit
import Then

class KeyboardView: UIView {
    private let rows: [[String]] = [
        ["ㅂ","ㅈ","ㄷ","ㄱ","ㅅ","ㅛ","ㅕ","ㅑ"],
        ["ㅁ","ㄴ","ㅇ","ㄹ","ㅎ","ㅗ","ㅓ","ㅏ","ㅣ"],
        ["ㅋ","ㅌ","ㅊ","ㅍ","ㅠ","ㅜ","ㅡ"]
    ]

    var onJamoTapped: ((String) -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onSubmitTapped: (() -> Void)?

    private var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    private var jamoButtons: [String: UIButton] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }

        for (i, row) in rows.enumerated() {
            let hStack = UIStackView().then {
                $0.axis = .horizontal
                $0.spacing = 6
                $0.alignment = .fill
                $0.distribution = .fillEqually
            }

            if i == rows.count - 1 {
                // 삭제 버튼
                let deleteButton = makeSystemButton(icon: "delete.left")
                deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
                hStack.addArrangedSubview(deleteButton)
            }

            for jamo in row {
                let button = makeJamoButton(title: jamo)
                button.addTarget(self, action: #selector(jamoTapped(_:)), for: .touchUpInside)
                hStack.addArrangedSubview(button)
                jamoButtons[jamo] = button
            }

            if i == rows.count - 1 {
                // 확인 버튼
                let submitButton = makeSystemButton(icon: "checkmark")
                submitButton.backgroundColor = .blue_5
                submitButton.tintColor = .gray_0
                submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
                hStack.addArrangedSubview(submitButton)
            }

            stackView.addArrangedSubview(hStack)
        }
    }

    private func makeJamoButton(title: String) -> UIButton {
        let button = UIButton(type: .system).then {
                        $0.setTitle(title, for: .normal)
                        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
                        $0.backgroundColor = .blue_1
                        $0.layer.cornerRadius = 6
                        $0.setTitleColor(.label, for: .normal)
                    }
        button.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        return button
    }

    private func makeSystemButton(icon: String) -> UIButton {
        return UIButton(type: .system).then {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            $0.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
            $0.backgroundColor = UIColor.systemGray4
            $0.tintColor = .label
            $0.layer.cornerRadius = 6
        }
    }
    
    // MARK: Public Methods
    
    func updateKeyboardColors(_ colors: [String: TileColor]) {
        for (jamo, button) in jamoButtons {
            if let color = colors[jamo] {
                switch color {
                case .blue:
                    button.backgroundColor = .blue_5
                    button.setTitleColor(.white, for: .normal)
                case .lightBlue:
                    button.backgroundColor = .blue_4
                    button.setTitleColor(.white, for: .normal)
                case .default:
                    button.backgroundColor = .gray_2
                    button.setTitleColor(.label, for: .normal)
                default:
                    break
                }
            } else {
                // 기본값
                button.backgroundColor = .blue_1
                button.setTitleColor(.label, for: .normal)
            }
        }
    }

    // MARK: Actions

    @objc private func jamoTapped(_ sender: UIButton) {
        guard let jamo = sender.titleLabel?.text else { return }
        onJamoTapped?(jamo)
    }

    @objc private func deleteTapped() {
        onDeleteTapped?()
    }

    @objc private func submitTapped() {
        onSubmitTapped?()
    }
}
