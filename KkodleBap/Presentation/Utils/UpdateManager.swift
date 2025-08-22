//
//  UpdateManager.swift
//  KkodleBap
//
//  Created by gomin on 8/22/25.
//

import StoreKit
import UIKit

final class UpdateManager {

    enum UpdateKind { case none, recommended(appStoreUrl: String), forced(appStoreUrl: String) }

    private let policyProvider: RemotePolicyProvider

    init(policyProvider: RemotePolicyProvider = DefaultPolicyProvider()) {
        self.policyProvider = policyProvider
    }

    func checkAndPresentIfNeeded(from presenter: UIViewController) async {
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let policy = await policyProvider.fetchPolicy()

        // 1) App Store 최신 버전 조회 (권장 기준 기본값)
        guard let latest = try? await AppStoreLookupService.fetchLatestVersion(),
              !latest.version.isEmpty else { return }

        let minRequired = policy.minRequiredVersion
        let minRecommended = policy.minRecommendedVersion ?? latest.version

        let kind: UpdateKind
        if let minRequired, Version.isLower(current, than: minRequired) {
            kind = .forced(appStoreUrl: latest.url)
        } else if Version.isLower(current, than: minRecommended) {
            kind = .recommended(appStoreUrl: latest.url)
        } else {
            kind = .none
        }

        switch kind {
        case .none:
            break
        case .recommended(let url):
            await self.presentRecommended(from: presenter, storeUrl: url, latestVersion: latest.version, current: current)
        case .forced(let url):
            self.presentForced(from: presenter, storeUrl: url, latestVersion: latest.version, current: current)
        }
    }

    private func openStore(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func presentRecommended(from vc: UIViewController, storeUrl: String, latestVersion: String, current: String) async {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                KoodleAlert.Builder()
                    .setTitle("업데이트가 있어요")
                    .setMessage("새로워진 꼬들밥을 만나러 가실까요?")
                    .addAction(.init("나중에", style: .secondary) {
                        vc.dismiss(animated: true)
                        continuation.resume()
                    })
                    .addAction(.init("지금 업데이트", style: .primary) {
                        vc.dismiss(animated: true) {
                            self.openStore(storeUrl)
                            continuation.resume()
                        }
                    })
                    .present(from: vc)
            }
        }
    }
    
    private func presentForced(from vc: UIViewController, storeUrl: String, latestVersion: String, current: String) {
        KoodleAlert.Builder()
            .setTitle("업데이트가 필요해요")
            .setMessage("꼬들밥을 계속 사용하시려면 앱을 업데이트해주세요.")
            .addAction(.init("업데이트", style: .primary) {
                self.openStore(storeUrl)
            })
            .present(from: vc)
    }
}
struct UpdatePolicy {
    /// 이 버전 미만이면 강제 업데이트
    let minRequiredVersion: String?
    /// 이 버전 미만이면 권장 업데이트 (없으면 App Store 최신 버전 사용)
    let minRecommendedVersion: String?
}

protocol RemotePolicyProvider {
    func fetchPolicy() async -> UpdatePolicy
}

/// 예시: 원격 없음 → 기본 정책
final class DefaultPolicyProvider: RemotePolicyProvider {
    func fetchPolicy() async -> UpdatePolicy {
        return UpdatePolicy(minRequiredVersion: nil, minRecommendedVersion: nil)
    }
}
struct AppStoreInfo: Decodable {
    let resultCount: Int
    let results: [Result]

    struct Result: Decodable {
        let version: String
        let trackViewUrl: String
    }
}

final class AppStoreLookupService {
    /// 국가코드는 한국이면 "KR". 번들ID 기반 조회가 안전합니다.
    static func fetchLatestVersion(bundleId: String = Bundle.main.bundleIdentifier ?? "",
                                   country: String = "KR") async throws -> (version: String, url: String)? {
        guard !bundleId.isEmpty else { return nil }
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)&country=\(country)"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(AppStoreInfo.self, from: data)
        guard let first = decoded.results.first else { return nil }
        return (first.version, first.trackViewUrl)
    }
}
enum VersionCompareResult { case orderedAscending, orderedSame, orderedDescending }

struct Version {
    static func compare(_ a: String, _ b: String) -> VersionCompareResult {
        let compsA = a.split(separator: ".").map { Int($0) ?? 0 }
        let compsB = b.split(separator: ".").map { Int($0) ?? 0 }
        let count = max(compsA.count, compsB.count)
        for i in 0..<count {
            let ai = i < compsA.count ? compsA[i] : 0
            let bi = i < compsB.count ? compsB[i] : 0
            if ai < bi { return .orderedAscending }
            if ai > bi { return .orderedDescending }
        }
        return .orderedSame
    }

    static func isLower(_ current: String, than target: String) -> Bool {
        return compare(current, target) == .orderedAscending
    }
}
