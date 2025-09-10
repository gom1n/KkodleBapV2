//
//  AdMobViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/23/25.
//

import UIKit
import SnapKit
import Then
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class AdMobViewController: UIViewController, FullScreenContentDelegate {
    
    private var rewardedAd: RewardedAd?
    public var rewardAction: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray_0
        
        setupViews()
        // 권한 허용 알럿창
        requestATTIfNeeded()
        
        Task {
            do {
                
                await MobileAds.shared.start()
                await loadRewardedAd()
                
                rewardedAd?.present(from: self) {
                    let reward = self.rewardedAd?.adReward
                    print("Reward received with currency \(reward?.amount), amount \(reward?.amount.doubleValue)")
                    
                    // Reward
                    self.dismiss(animated: false) {
                        self.rewardAction?(true)
                    }
                }
            } catch {
                throw error
            }
        }
    }

    private func setupViews() {
        
    }

    func loadRewardedAd() async {
        do {
            rewardedAd = try await RewardedAd.load(
                // 보상형 광고 단위 ID
                with: "ca-app-pub-8570424711351250/9077790887", request: Request())
            rewardedAd?.fullScreenContentDelegate = self
        } catch {
            print("Rewarded ad failed to load with error: \(error.localizedDescription)")
            
            self.dismiss(animated: false) {
                self.rewardAction?(false)
            }
        }
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("\(#function) called.")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("\(#function) called.")
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("\(#function) called.")
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        // 광고 꺼질 때 호출
        print("\(#function) called.")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        // 광고 꺼진 직후 호출
        print("\(#function) called.")
        
        // Clear the rewarded ad.
        rewardedAd = nil
        self.dismiss(animated: false)
    }

    func ad(
      _ ad: FullScreenPresentingAd,
      didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("\(#function) called with error: \(error.localizedDescription).")
        
        self.dismiss(animated: false) {
            self.rewardAction?(false)
        }
    }
}

extension AdMobViewController {
    /// ATT 여부 확인 및 권한 허용 알럿창 노출
    func requestATTIfNeeded() {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            switch status {
            case .notDetermined:
                // 아직 동의 여부를 물어본 적 없음 → 요청 가능
                ATTrackingManager.requestTrackingAuthorization { newStatus in
                    print("New status: \(newStatus.rawValue)")
                }
            case .authorized:
                print("Already authorized. IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied, .restricted:
                print("Tracking not allowed")
            @unknown default:
                break
            }
        }
    }
}
