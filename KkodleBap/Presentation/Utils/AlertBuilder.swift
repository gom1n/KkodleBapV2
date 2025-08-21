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
        private var title: String?
        private var message: String?
        private var customViews: [UIView] = []
        private var actions: [KoodleAlertAction] = []

        public init() {}

        @discardableResult
        public func setTitle(_ text: String?) -> Builder {
            self.title = text; return self
        }
        @discardableResult
        public func setMessage(_ text: String?) -> Builder {
            self.message = text; return self
        }
        /// 스택뷰 안에 넣을 커스텀 뷰(예: 이미지, 텍스트필드 등)
        @discardableResult
        public func addCustomView(_ view: UIView) -> Builder {
            self.customViews.append(view); return self
        }
        @discardableResult
        public func addAction(_ action: KoodleAlertAction) -> Builder {
            guard actions.count < 2 else { return self } // 1~2개 제한
            self.actions.append(action); return self
        }

        public func build() -> KoodleAlertViewController {
            return KoodleAlertViewController(title: title,
                                             message: message,
                                             customViews: customViews,
                                             actions: actions.isEmpty
                                                ? [KoodleAlertAction("OK", style: .primary, handler: nil)]
                                                : actions)
        }

        public func present(from presenter: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
            let vc = build()
            presenter.present(vc, animated: animated, completion: completion)
        }
    }
}
