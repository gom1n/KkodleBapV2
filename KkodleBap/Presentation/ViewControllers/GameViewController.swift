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
    
    private let bapContainer = UIView().then {
        $0.isUserInteractionEnabled = true
    }
    
    private let bapImage = UIImageView().then {
        $0.image = .bap.withRenderingMode(.alwaysOriginal)
        $0.contentMode = .scaleAspectFit
    }
    
    private let bapCount = UILabel().then {
        $0.text = "1"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let mapButton = UIButton().then {
        $0.setTitle("맵 보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    private let historyButton = UIButton().then {
        $0.setTitle("히스토리 보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(bapContainer)
        view.addSubview(mapButton)
        view.addSubview(historyButton)
        bapContainer.addSubview(bapImage)
        bapContainer.addSubview(bapCount)
        scrollView.addSubview(tileContainer)
        view.addSubview(scrollView)
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
        
        bapContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(4)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        bapImage.snp.makeConstraints {
            $0.leading.centerY.top.bottom.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        
        bapCount.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.leading.equalTo(bapImage.snp.trailing).offset(4)
        }
        
        mapButton.snp.makeConstraints { make in
            make.centerY.equalTo(bapContainer)
            make.leading.equalToSuperview().offset(20)
        }
        
        historyButton.snp.makeConstraints { make in
            make.top.equalTo(mapButton.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.bottom.equalTo(keyboardView.snp.top).offset(-60)
        }
        
        tileContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        keyboardView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bapTapped))
        bapContainer.addGestureRecognizer(tapGesture)
        
        mapButton.addTarget(self, action: #selector(moveToMap), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(moveToHistory), for: .touchUpInside)
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
    
    private func renderTiles(completion: (() -> Void)? = nil) {
        tileContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let answerCount = viewModel.ANSWER_COUNT
        let screenWidth = UIScreen.main.bounds.width
        let tileContainerSize: CGFloat = (screenWidth - 45 * 2) - (CGFloat(answerCount - 1) * 8)
        let tileSize: CGFloat = tileContainerSize / CGFloat(answerCount)
        
        for row in 0..<viewModel.MAX_ATTEMPTS {
            let hStack = UIStackView().then {
                $0.axis = .horizontal
                $0.spacing = 8
                $0.distribution = .equalSpacing
                $0.alignment = .center
            }
            
            let isBonus = row >= viewModel.BASE_MAX_ATTEMPTS
            if row < viewModel.attempts.count {
                let tiles = viewModel.attempts[row]
                for tile in tiles {
                    let view = TileView(character: tile.character, color: tile.color, size: tileSize, isBonus: isBonus)
                    hStack.addArrangedSubview(view)
                }
            } else if row == viewModel.attempts.count {
                for i in 0..<answerCount {
                    let character = viewModel.currentInput.indices.contains(i) ? viewModel.currentInput[i] : ""
                    let view = TileView(character: character, size: tileSize, isBonus: isBonus)
                    hStack.addArrangedSubview(view)
                }
            } else {
                for _ in 0..<answerCount {
                    let view = TileView(size: tileSize, isBonus: isBonus)
                    hStack.addArrangedSubview(view)
                }
            }
            
            tileContainer.addArrangedSubview(hStack)
            completion?()
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
            self.showSuccessAlert()
        } else {
            self.showChallengeAlert()
        }
    }
    
    private func showSuccessAlert() {
        // 기기에 히스토리 저장
        let resultImage = self.tileContainer.captureAsImage()
        let imagePath = self.saveImage(resultImage, fileName: UUID().uuidString)
        HistoryStore.add(HistoryEntry(answer: viewModel.rawAnswer, didWin: viewModel.didWin, imagePath: imagePath))
        
        // TODO: 성공 image
        
        KoodleAlert.Builder()
            .setTitle(viewModel.rawAnswer)
            .setMessage("축하합니다!\n밥풀을 모은 꼬들이는 행복해요.")
            .addAction(.init("결과 복사하기", style: .secondary) {
                self.viewModel.copyResultToClipboard()
                self.showToast(message: "결과가 복사되었습니다.🍚")
            })
            .addAction(.init("새로 시작", style: .primary) {
                self.dismiss(animated: true) {
                    self.viewModel.resetGame()
                    self.renderTiles()
                }
            })
            .present(from: self)
    }
    
    private func showChallengeAlert() {
        let imageView = UIImageView(image: .kkodle0)
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        KoodleAlert.Builder()
            .setTitle("이어서 더 도전해볼까요?")
            .setMessage("꼬들밥 한 그릇으로 기회를 한 번 더 얻을 수 있습니다.")
            .addCustomView(imageView)
            .addAction(.init("그만할래요", style: .secondary) {
                // 새로 시작
                self.dismiss(animated: false) {
                    self.showFailAlert()
                }
            })
            .addAction(.init("계속할래요", style: .primary) {
                // TODO: Logic
                
                self.dismiss(animated: true)
                self.viewModel.grantOneMoreChanceIfPossible()
                self.renderTiles()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.scrollView.scrollToBottom()
                }
                
            })
            .present(from: self)
    }
    
    private func showFailAlert() {
        // 기기에 히스토리 저장
        let resultImage = self.tileContainer.captureAsImage()
        let imagePath = self.saveImage(resultImage, fileName: UUID().uuidString)
        HistoryStore.add(HistoryEntry(answer: viewModel.rawAnswer, didWin: viewModel.didWin, imagePath: imagePath))
        
        // 알럿창
        let imageView = UIImageView(image: .kkodle0)
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        KoodleAlert.Builder()
            .setTitle(self.viewModel.rawAnswer)
            .setMessage("텅 - 다시 한번 해볼까요?")
            .addCustomView(imageView)
            .addAction(.init("새로 시작", style: .secondary) {
                self.dismiss(animated: true) {
                    self.viewModel.resetGame()
                    self.renderTiles()
                }
            })
            .present(from: self)
    }
    
    @objc private func bapTapped() {
        // 진동
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // TODO: Logic
    }
    
    @objc private func moveToMap() {
        // 진동
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let mapVC = MapsViewController()
        mapVC.mapChangeAction = { [weak self] in
            self?.viewModel.resetGame()
            self?.renderTiles()
        }
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @objc private func moveToHistory() {
        // 진동
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let vc = HistoryViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension GameViewController {
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel().then {
            $0.text = message
            $0.textColor = .gray_0
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 14)
            $0.backgroundColor = .gray_3
            $0.numberOfLines = 0
            $0.alpha = 0
            $0.layer.cornerRadius = 18
            $0.layer.masksToBounds = true
        }
        
        guard let topVC = self.topViewController() else { return }
        topVC.view.addSubview(toastLabel)
        
        toastLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(36)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-60)
        }
        
        // 애니메이션: 페이드 인 → 잠시 유지 → 페이드 아웃
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    func saveImage(_ image: UIImage, fileName: String) -> String? {
        guard let data = image.pngData() else { return nil }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(fileName).png")

        do {
            try data.write(to: url)
            return url.path
        } catch {
            print("❌ 이미지 저장 실패:", error)
            return nil
        }
    }
}

extension UIScrollView {
    func scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(
            x: 0,
            y: max(0, contentSize.height - bounds.size.height + adjustedContentInset.bottom)
        )
        setContentOffset(bottomOffset, animated: animated)
    }
}

extension UIView {
    func captureAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
    }
}
