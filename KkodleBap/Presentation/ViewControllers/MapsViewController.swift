//
//  MapsViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/23/25.
//

import UIKit
import SnapKit
import Then

public enum MapPageEntry {
    case onboarding
    case menu
}

final class MapsViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var items: [MapItem] = [
        MapItem(name: "현미밥 (5자리)", length: .five, imageName: "map_5", locked: UserManager.map5Locked),
        MapItem(name: "꼬들밥 (6자리)", length: .six, imageName: "map_6", locked: UserManager.map6Locked),
        MapItem(name: "콩밥 (7자리)", length: .seven, imageName: "map_7", locked: UserManager.map7Locked),
        MapItem(name: "흑미밥 (8자리)", length: .eight, imageName: "map_8", locked: UserManager.map8Locked)
    ]
    
    public var mapChangeAction: (() -> Void)?
    private let entry: MapPageEntry
    
    // MARK: - Initializers
    
    init(entry: MapPageEntry = .onboarding) {
        self.entry = entry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray_0
        self.navigationController?.isNavigationBarHidden = false
        
        configureNavigationBar()
        configureCollectionView()
    }
    
    // MARK: - Methods

    // 🔙 네비게이션 바 설정
    private func configureNavigationBar() {
        navigationItem.title = "맵 선택"
        
        switch self.entry {
        case .onboarding:
            break
        case .menu:
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapBack)
            )
        }
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
        print("Selected map:", item.name, "length:", item.length.rawValue)
        
        if item.locked {
            let needBapCount = item.length.rawValue
            
            let container = UIView()
            let imageContainer = UIView()
            let bapImage = UIImageView().then {
                $0.image = .bap
            }
            let countLabel = UILabel().then {
                $0.text = String("X \(needBapCount)")
                $0.textColor = .black
                $0.font = .systemFont(ofSize: 28, weight: .bold)
                $0.textAlignment = .center
            }
            
            container.addSubview(imageContainer)
            imageContainer.addSubview(bapImage)
            imageContainer.addSubview(countLabel)
            
            bapImage.snp.makeConstraints { make in
                make.width.height.equalTo(80)
                make.top.leading.bottom.equalToSuperview()
            }
            countLabel.snp.makeConstraints { make in
                make.leading.equalTo(bapImage.snp.trailing).offset(8)
                make.centerY.equalTo(bapImage)
                make.trailing.equalToSuperview()
            }
            imageContainer.snp.makeConstraints { make in
                make.centerY.centerX.equalToSuperview()
                make.top.bottom.equalToSuperview()
            }
            
            let builder = KoodleAlert.Builder()
                            .setTitle("꼬들밥을 소진해 \(needBapCount)자리 맵을 경험해보세요!")
                            .setMessage("꼬들밥 \(needBapCount)개 소진하시겠습니까?")
                            .addCustomView(container)
                            .addAction(.init("다음에", style: .secondary) { [weak self] in
                                self?.dismiss(animated: true)
                            })
            
            // 꼬들밥 개수가 있을 때
            if UserManager.bap >= needBapCount {
                builder.addAction(.init("네!", style: .primary) { [weak self] in
                    self?.dismiss(animated: true)
                    // 꼬들밥 그릇 소진
                    UserManager.bap -= needBapCount
                    // 맵 진입
                    UserManager.mapVersion = item.length.rawValue
                    // 맵 잠금 해제
                    switch item.length {
                    case .five:
                        UserManager.map5Locked = false
                    case .six:
                        UserManager.map6Locked = false
                    case .seven:
                        UserManager.map7Locked = false
                    case .eight:
                        UserManager.map8Locked = false
                    }
                    
                    self?.moveToSelectedMap()
                })
            }
            
            builder.present()
            
        } else {
            // 맵 선택
            UserManager.mapVersion = item.length.rawValue
            self.moveToSelectedMap()
        }
    }
    
    /// 선택한 맵으로 이동
    private func moveToSelectedMap() {
        // 진동
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        switch self.entry {
        case .onboarding:
            guard let window = UIApplication.shared.windows.first else { return }
            let targetVC = GameViewController() // 게임 화면으로 이동
            let nav = UINavigationController(rootViewController: targetVC)
            
            // 전환 애니메이션
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve, // 자연스럽게 페이드 인/아웃
                              animations: {
                                  window.rootViewController = nav
                              }, completion: nil)
        case .menu:
            self.navigationController?.popViewController(animated: true)
            self.mapChangeAction?()
        }
    }
}
