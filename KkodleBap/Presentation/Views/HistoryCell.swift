//
//  HistoryCell.swift
//  KkodleBap
//
//  Created by gomin on 8/23/25.
//

import UIKit
import SnapKit
import Then
import Foundation

final class HistoryCell: UITableViewCell {
    static let reuseID = "HistoryCell"

    private let timeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .secondaryLabel
    }
    private let answerLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    private let badge = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .bold)
        $0.textAlignment = .center
        $0.textColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let hStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }
    private let vStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        vStack.addArrangedSubview(answerLabel)
        vStack.addArrangedSubview(timeLabel)

        hStack.addArrangedSubview(vStack)
        hStack.addArrangedSubview(badge)

        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
            badge.heightAnchor.constraint(equalToConstant: 20)
        ])
        accessoryType = .disclosureIndicator // 필요 없으면 지워도 됨
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(timeText: String, answer: String, didWin: Bool) {
        timeLabel.text = timeText
        answerLabel.text = answer
        badge.text = didWin ? "성공" : "실패"
        badge.backgroundColor = didWin ? UIColor.systemBlue : UIColor.red
    }
}
