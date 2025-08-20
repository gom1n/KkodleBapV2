//
//  JamoHelper.swift
//  KkodleBap
//
//  Created by gomin on 8/7/25.
//

import Foundation

enum Jamo {
    static let choseong = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ",
                    "ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
    static let jungseong = ["ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ","ㅘ","ㅙ","ㅚ",
                     "ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ","ㅡ","ㅢ","ㅣ"]
    static let jongseong = ["","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ","ㄻ","ㄼ",
                     "ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ","ㅆ","ㅇ","ㅈ",
                     "ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
    
    static let complexChoseongMap: [String: [String]] = [
        "ㄲ": ["ㄱ", "ㄱ"],  "ㄸ": ["ㄷ", "ㄷ"],  "ㅃ": ["ㅂ", "ㅂ"],
        "ㅆ": ["ㅅ", "ㅅ"],  "ㅉ": ["ㅈ", "ㅈ"]
    ]

    // 복합 중성 분해 테이블
    static let complexVowelMap: [String: [String]] = [
        "ㅘ": ["ㅗ", "ㅏ"], "ㅙ": ["ㅗ", "ㅏ", "ㅣ"], "ㅚ": ["ㅗ", "ㅣ"],
        "ㅝ": ["ㅜ", "ㅓ"], "ㅞ": ["ㅜ", "ㅓ", "ㅣ"], "ㅟ": ["ㅜ", "ㅣ"],
        "ㅢ": ["ㅡ", "ㅣ"], "ㅐ": ["ㅏ", "ㅣ"], "ㅔ": ["ㅓ", "ㅣ"],
        "ㅒ": ["ㅑ", "ㅣ"], "ㅖ": ["ㅕ", "ㅣ"]
    ]

    // 복합 종성 분해 테이블
    static let complexFinalMap: [String: [String]] = [
        "ㄳ": ["ㄱ", "ㅅ"], "ㄵ": ["ㄴ", "ㅈ"], "ㄶ": ["ㄴ", "ㅎ"],
        "ㄺ": ["ㄹ", "ㄱ"], "ㄻ": ["ㄹ", "ㅁ"], "ㄼ": ["ㄹ", "ㅂ"],
        "ㄽ": ["ㄹ", "ㅅ"], "ㄾ": ["ㄹ", "ㅌ"], "ㄿ": ["ㄹ", "ㅍ"], "ㅀ": ["ㄹ", "ㅎ"],
        "ㅄ": ["ㅂ", "ㅅ"], "ㄲ": ["ㄱ", "ㄱ"], "ㅆ": ["ㅅ", "ㅅ"]
    ]
    
    static func decompose(_ text: String) -> [String] {
        var result: [String] = []

        for scalar in text.unicodeScalars {
            let code = scalar.value

            if code >= 0xAC00 && code <= 0xD7A3 {
                let base = code - 0xAC00
                let cho = Int(base / (21 * 28))
                let jung = Int((base % (21 * 28)) / 28)
                let jong = Int(base % 28)

//                result.append(choseong[cho])
                
                let choChar = choseong[cho]
                if let parts = complexChoseongMap[choChar] {
                    result.append(contentsOf: parts)
                } else {
                    result.append(choChar)
                }

                let jungChar = jungseong[jung]
                if let parts = complexVowelMap[jungChar] {
                    result.append(contentsOf: parts)
                } else {
                    result.append(jungChar)
                }

                if jong > 0 {
                    let jongChar = jongseong[jong]
                    if let parts = complexFinalMap[jongChar] {
                        result.append(contentsOf: parts)
                    } else {
                        result.append(jongChar)
                    }
                }
            } else {
                result.append(String(scalar))
            }
        }

        return result
    }
}
