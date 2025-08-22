//
//  TileView.swift
//  KkodleBap
//
//  Created by gomin on 8/7/25.
//

import UIKit
import SnapKit
import Then

enum TileColor {
    case gray, lightBlue, blue

    var backgroundColor: UIColor {
        switch self {
        case .gray: return .blue_1
        case .lightBlue: return .blue_4
        case .blue: return .blue_5
        }
    }
}

class TileView: UIView {
    private let label = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .label
    }

    private var color: TileColor = .gray {
        didSet {
            backgroundColor = color.backgroundColor
        }
    }
    
    private let size: CGFloat

    init(character: String = "", color: TileColor = .gray, size: CGFloat = 44) {
        self.size = size
        
        super.init(frame: .zero)
        
        self.label.text = character
        self.color = color
        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.cornerRadius = 8
        backgroundColor = color.backgroundColor

        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        snp.makeConstraints { make in
            make.width.height.equalTo(size)
        }
    }

    func configure(character: String, color: TileColor = .gray) {
        label.text = character
        self.color = color
    }

    func setColor(_ color: TileColor) {
        self.color = color
    }

    func setCharacter(_ character: String) {
        label.text = character
    }
}
