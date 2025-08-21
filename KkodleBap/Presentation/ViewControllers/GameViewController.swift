//
//  GameViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/7/25.
//

import UIKit
import SnapKit
import Then

class GameViewController: UIViewController {
    private let titleLabel = UILabel().then {
        $0.text = "꼬들밥"
        $0.font = .boldSystemFont(ofSize: 36)
        $0.textColor = .label
        $0.textAlignment = .center
    }
    
    private let subtitleLabel = UILabel().then {
        $0.text = "한글 자모 맞추기 게임"
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = .systemGray4
        $0.textAlignment = .center
    }
    
    private let questionButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        $0.tintColor = .gray
//        $0.addTarget(self, action: #selector(didTapQuestion), for: .touchUpInside)
    }
    
    private let tileContainer = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    
    private let errorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .systemRed
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private let keyboardView = KeyboardView()
    private let viewModel = GameViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray_0
        setupLayout()
        setupKeyboardCallbacks()
        renderTiles()
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(questionButton)
        view.addSubview(tileContainer)
        view.addSubview(errorLabel)
        view.addSubview(keyboardView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }
        
        questionButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(30)
        }
        
        tileContainer.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(tileContainer.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        keyboardView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(tileContainer.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
    
    private func setupKeyboardCallbacks() {
        keyboardView.onJamoTapped = { [weak self] jamo in
            self?.viewModel.addJamo(jamo)
            self?.renderTiles()
        }
        
        keyboardView.onDeleteTapped = { [weak self] in
            self?.viewModel.removeLast()
            self?.renderTiles()
        }
        
        keyboardView.onSubmitTapped = { [weak self] in
            self?.viewModel.submit()
            self?.renderTiles()
            self?.checkGameResult()
        }
    }
    
    private func renderTiles() {
        tileContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for row in 0..<6 {
            let hStack = UIStackView().then {
                $0.axis = .horizontal
                $0.spacing = 8
                $0.distribution = .equalSpacing
                $0.alignment = .center
            }
            
            if row < viewModel.attempts.count {
                let tiles = viewModel.attempts[row]
                for tile in tiles {
                    let view = TileView(character: tile.character, color: tile.color)
                    hStack.addArrangedSubview(view)
                }
            } else if row == viewModel.attempts.count {
                for i in 0..<6 {
                    let character = viewModel.currentInput.indices.contains(i) ? viewModel.currentInput[i] : ""
                    let view = TileView(character: character)
                    hStack.addArrangedSubview(view)
                }
            } else {
                for _ in 0..<6 {
                    let view = TileView()
                    hStack.addArrangedSubview(view)
                }
            }
            
            tileContainer.addArrangedSubview(hStack)
        }
        
        if let error = viewModel.errorMessage {
            errorLabel.text = error
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
        
        // Keyboard
        self.keyboardView.updateKeyboardColors(viewModel.keyboardColors)
    }
    
    private func checkGameResult() {
        guard viewModel.isGameOver else { return }
        if viewModel.didWin {
            KoodleAlert.Builder()
                .setTitle(viewModel.rawAnswer)
                .setMessage("축하합니다!\n밥풀을 모은 꼬들이는 행복해요.")
                .addAction(.init("결과 복사하기", style: .secondary) {
                    self.viewModel.copyResultToClipboard()
                })
                .addAction(.init("새로 시작", style: .primary) {
                    self.viewModel.resetGame()
                    self.renderTiles()
                })
                .present(from: self)
        } else {
            let imageView = UIImageView(image: .kkodle0)
            imageView.contentMode = .scaleAspectFit
            imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
            
            KoodleAlert.Builder()
                .setTitle(viewModel.rawAnswer)
                .setMessage("텅 - 다시 한번 해볼까요?")
                .addCustomView(imageView)
                .addAction(.init("새로 시작", style: .secondary) {
                    self.viewModel.resetGame()
                    self.renderTiles()
                })
                .addAction(.init("광고 보고 맞춰보기", style: .primary) {
                    // TODO: Logic
                })
                .present(from: self)
        }
    }
    
    private func showAlert(
        title: String,
        message: String,
        imageName: String,
        subtext: String,
        showCopy: Bool
    ) {
        let alert = UIAlertController(title: title, message: "\(message)\n\(subtext)", preferredStyle: .alert)
        
        if showCopy {
            alert.addAction(UIAlertAction(title: "📋 결과 복사하기", style: .default) { _ in
                self.viewModel.copyResultToClipboard()
            })
        }
        
        alert.addAction(UIAlertAction(title: "다시 시작", style: .default) { _ in
            self.viewModel.resetGame()
            self.renderTiles()
        })
        
        present(alert, animated: true)
    }
}
