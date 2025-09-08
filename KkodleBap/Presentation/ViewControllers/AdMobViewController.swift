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

class AdMobViewController: UIViewController, FullScreenContentDelegate {
    
    private var rewardedAd: RewardedAd?
    public var rewardAction: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray_0
        
        setupViews()
        
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
                // 보상형 광고 앱 ID
                // 테스트용: ca-app-pub-3940256099942544~1458002511
                with: "ca-app-pub-8570424711351250~9069249695", request: Request())
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
