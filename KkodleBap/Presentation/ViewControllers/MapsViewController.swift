//
//  MapsViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/23/25.
//

import UIKit
import SnapKit
import Then

final class MapsViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var items: [MapItem] = [
        MapItem(name: "5자리 맵", length: .five, imageName: nil),
        MapItem(name: "6자리 맵", length: .six, imageName: nil),
        MapItem(name: "7자리 맵", length: .seven, imageName: nil),
        MapItem(name: "8자리 맵", length: .eight, imageName: nil)
    ]
    
    public var mapChangeAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray_0
        self.navigationController?.isNavigationBarHidden = false
        
        configureNavigationBar()
        configureCollectionView()
    }

    // 🔙 네비게이션 바 설정
    private func configureNavigationBar() {
        navigationItem.title = "맵 선택"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapBack)
        )
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.sectionInset = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(150)
            make.leading.equalToSuperview().offset(45)
            make.trailing.equalToSuperview()
        }

        collectionView.register(MapCell.self, forCellWithReuseIdentifier: MapCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension MapsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapCell.reuseID, for: indexPath) as! MapCell
        cell.configure(items[indexPath.item])
        return cell
    }
}

extension MapsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        UserManager.mapVersion = item.length.rawValue
        mapChangeAction?()
        print("Selected map:", item.name, "length:", item.length.rawValue)
    }
}
