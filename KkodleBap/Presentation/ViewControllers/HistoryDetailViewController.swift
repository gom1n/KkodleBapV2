//
//  HistoryDetailViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/23/25.
//

import UIKit

final class HistoryDetailViewController: UIViewController {
    private let imageView = UIImageView()

    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        view.backgroundColor = .gray_0

        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // 닫기 버튼
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf)
        )
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}
