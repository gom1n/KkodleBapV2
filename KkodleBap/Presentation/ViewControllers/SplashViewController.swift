//
//  SplashViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/7/25.
//


import UIKit
import SnapKit
import Then

class SplashViewController: UIViewController {
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "kkodle")
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0
    }

    private let titleLabel = UILabel().then {
        $0.text = "꼬들밥"
        $0.font = .boldSystemFont(ofSize: 48)
        $0.textColor = .label
        $0.textAlignment = .center
        $0.alpha = 0
    }

    private let subtitleLabel = UILabel().then {
        $0.text = "한글 자모 맞추기 게임"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .systemGray2
        $0.textAlignment = .center
        $0.alpha = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        animateViews()
    }

    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.width.height.equalTo(320)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
    }

    private func animateViews() {
        UIView.animate(withDuration: 1.2, animations: {
            self.imageView.alpha = 1
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let gameVC = GameViewController()
                let nav = UINavigationController(rootViewController: gameVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
}
