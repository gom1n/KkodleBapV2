//
//  MapCell.swift
//  KkodleBap
//
//  Created by gomin on 8/23/25.
//

import UIKit
import SnapKit
import Then

enum MapLength: Int, CaseIterable {
    case six = 6, seven = 7, eight = 8, five = 5

    // 원하는 노출 순서
    static var displayOrder: [MapLength] { [.six, .seven, .five, .eight] }

    var title: String {
        switch self {
        case .five: return "5자리"
        case .six: return "6자리"
        case .seven: return "7자리"
        case .eight: return "8자리"
        }
    }
}

struct MapItem: Hashable {
    let id = UUID()
    let name: String
    let length: MapLength
    let imageName: String? // 썸네일 에셋 이름(옵션)
}

final class MapCell: UICollectionViewCell {
    static let reuseID = "MapCell"

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(imageView.snp.bottom).offset(-4)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(_ item: MapItem) {
        titleLabel.text = item.name
        if let name = item.imageName, let img = UIImage(named: name) {
            imageView.image = img
        } else {
            imageView.image = UIImage(systemName: "map") // 플레이스홀더
            imageView.tintColor = .tertiaryLabel
        }
    }
}
