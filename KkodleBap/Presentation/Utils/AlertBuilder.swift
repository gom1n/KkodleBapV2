//
//  AlertBuilder.swift
//  KkodleBap
//
//  Created by gomin on 8/21/25.
//

import Foundation
import UIKit

public enum KoodleAlert {}

public extension KoodleAlert {
    final class Builder {
        private let alert = KoodleAlertViewController()
        
        public init() {}

        /// 제목 설정
        @discardableResult
        public func setTitle(_ text: String?) -> Builder {
            alert.setTitle(text)
            return self
        }
        
        /// 정답 제목 설정
        @discardableResult
        public func setAnswerTitle(_ answer: String) -> Builder {
            alert.setAnswerTitle(answer)
            return self
        }
        
        /// 내용 설정
        @discardableResult
        public func setMessage(_ text: String?) -> Builder {
            alert.setMessage(text)
            return self
        }
        
        /// 스택뷰 안에 넣을 커스텀 뷰(예: 이미지, 텍스트필드 등)
        @discardableResult
        public func addCustomView(_ view: UIView) -> Builder {
            alert.addCustomView(view)
            return self
        }
        
        /// 버튼 추가
        @discardableResult
        public func addAction(_ action: KoodleAlertAction) -> Builder {
            alert.addButton(action)
            return self
        }
        
        /// 버튼들 추가
        @discardableResult
        public func addActions(_ actions: [KoodleAlertAction]) -> Builder {
            alert.addButtons(actions)
            return self
        }

        /// 생성
        private func build() -> KoodleAlertViewController {
            return alert
        }

        /// 노출
        public func present(from presenter: UIViewController? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
            let vc = build()
            if let presenter = presenter {
                presenter.present(vc, animated: animated, completion: completion)
            } else if let topVC = topViewController() {
                topVC.present(vc, animated: animated, completion: completion)
            }
        }
    }
}
