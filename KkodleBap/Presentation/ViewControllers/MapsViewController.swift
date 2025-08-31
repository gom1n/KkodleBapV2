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
        MapItem(name: "꼬들밥 (5자리)", length: .five, imageName: "map_5"),
        MapItem(name: "현미밥 (6자리)", length: .six, imageName: "map_6"),
        MapItem(name: "콩밥 (7자리)", length: .seven, imageName: "map_7"),
        MapItem(name: "흑미밥 (8자리)", length: .eight, imageName: "map_8")
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
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.sectionInset = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .gray_0
        collectionView.showsVerticalScrollIndicator = false

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(45)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
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
        let screenWidth = UIScreen.main.bounds.width
        let cellSize = (screenWidth - 20 * 3) / 2
        return CGSize(width: cellSize, height: cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        UserManager.mapVersion = item.length.rawValue
        self.navigationController?.popViewController(animated: true)
        mapChangeAction?()
        print("Selected map:", item.name, "length:", item.length.rawValue)
    }
}
