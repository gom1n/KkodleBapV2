//
//  HistoryDetailViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/23/25.
//

import UIKit
import SnapKit
import Then

final class HistoryDetailViewController: UIViewController {
    
    private let answerLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 30, weight: .bold)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let tryCountLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .secondaryLabel
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        $0.tintColor = .systemGray4
    }
    
    private let scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = true
    }
    private let contentView = UIView()
    
    private let copyButton = UIButton(type: .system).then{
        $0.setTitle("결과 복사하기", for: .normal)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        $0.titleLabel?.numberOfLines = 0
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.contentEdgeInsets = UIEdgeInsets(top: 14, left: 8, bottom: 14, right: 8)
        $0.backgroundColor = .blue_6
        $0.layer.borderColor = UIColor.clear.cgColor
        $0.layer.borderWidth = 0
        $0.setTitleColor(.gray_0, for: .normal)
    }
    
//    private let saveImageButton = UIButton(type: .system).then{
//        $0.setTitle("이미지 저장하기", for: .normal)
//        $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
//        $0.titleLabel?.numberOfLines = 0
//        $0.layer.cornerRadius = 8
//        $0.clipsToBounds = true
//        $0.contentEdgeInsets = UIEdgeInsets(top: 14, left: 8, bottom: 14, right: 8)
//        $0.backgroundColor = .gray_0
//        $0.layer.borderColor = UIColor.blue_6.cgColor
//        $0.layer.borderWidth = 1
//        $0.setTitleColor(.blue_6, for: .normal)
//    }
    
    // Properties
    
    private let item: HistoryEntry
    private var aspectRatioConstraint: Constraint?
    
    init(item: HistoryEntry, image: UIImage) {
        self.item = item
        
        super.init(nibName: nil, bundle: nil)
        
        answerLabel.text = item.answer
        imageView.image = image
        tryCountLabel.text = "시도 횟수: \(item.tryCount)"
        
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
//        saveImageButton.addTarget(self, action: #selector(saveImageButtonTapped), for: .touchUpInside)
        
        if let img = imageView.image {
           setImage(img)
       }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray_0

        view.addSubview(scrollView)
        view.addSubview(closeButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(answerLabel)
        contentView.addSubview(tryCountLabel)
        contentView.addSubview(imageView)
        view.addSubview(copyButton)
//        view.addSubview(saveImageButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(copyButton.snp.top).offset(-8)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width) // 가로 고정 → 세로 스크롤
        }
        
        answerLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(28)
        }
        
        tryCountLabel.snp.makeConstraints { make in
            make.top.equalTo(answerLabel.snp.bottom).offset(30)
            make.leading.equalTo(imageView)
        }
        
        // 이미지: 가로는 안전하게 맞추고, 세로는 ‘원본 비율’로 계산
        imageView.snp.makeConstraints { make in
            make.top.equalTo(tryCountLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
//            // 높이는 일단 placeholder (0)
//            self.imageHeightConstraint = make.height.equalTo(0).constraint
//            make.bottom.equalToSuperview().inset(24).priority(.low)
        }
        
//        copyButton.snp.makeConstraints { make in
//            make.height.equalTo(50)
//            make.leading.trailing.equalToSuperview().inset(16)
//            make.bottom.equalTo(saveImageButton.snp.top).offset(-16)
//        }
        
        copyButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    private func setImage(_ image: UIImage) {
        imageView.image = image
        
        // 기존 제약 해제 후 새로 설정
        aspectRatioConstraint?.deactivate()
        let ratio = image.size.height / image.size.width
        imageView.snp.makeConstraints { make in
            aspectRatioConstraint = make.height.equalTo(imageView.snp.width).multipliedBy(ratio).constraint
        }
    }

    @objc private func dismissView() {
        dismiss(animated: true)
    }
    
    @objc private func copyButtonTapped() {
        // 진동
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if let resultCopyString = self.item.resultCopyString {
            UIPasteboard.general.string = resultCopyString
        }
        
        // Toast
        self.showToast(message: "결과가 복사되었습니다.🍚")
    }
    
    @objc private func saveImageButtonTapped() {
        let renderer = UIGraphicsImageRenderer(bounds: contentView.bounds)
        let image = renderer.image { ctx in
            contentView.drawHierarchy(in: contentView.bounds, afterScreenUpdates: true)
        }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    // 저장 완료 콜백
    @objc private func imageSaveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.showToast(message: "이미지 저장에 실패하였습니다.")
        } else {
            self.showToast(message: "이미지가 앨범에 저장되었습니다.")
        }
    }
}
