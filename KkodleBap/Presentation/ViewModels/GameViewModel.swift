//
//  GameViewModel.swift
//  KkodleBap
//
//  Created by gomin on 8/7/25.
//

import Foundation
import SwiftUI


struct JamoTile: Identifiable, Hashable {
    let id = UUID()
    let character: String
    var color: TileColor = .gray
}

class GameViewModel: ObservableObject {
    @Published var currentInput: [String] = []
    @Published var attempts: [[JamoTile]] = []
    @Published var isGameOver = false
    @Published var didWin = false
    @Published var errorMessage: String?
    @Published var keyboardColors: [String: TileColor] = [:]

    public var rawAnswer: String = ""
    public var answer: [String] = []
    private let maxAttempts = 6
    
    private let validWordList: [String]
    private let decomposedWordList: [[String]]
    private let answerPool: [String]


    init() {
        // 정답 후보: common_nouns.txt
        if let answerPath = Bundle.main.path(forResource: "COMMON_NOUNS", ofType: "txt"),
           let answerContent = try? String(contentsOfFile: answerPath) {
            answerPool = answerContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
        } else {
            answerPool = []
        }

        // 유효성 검사용: all_nouns.txt
        if let validPath = Bundle.main.path(forResource: "ALL_NOUNS", ofType: "txt"),
           let validContent = try? String(contentsOfFile: validPath) {
            validWordList = validContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
        } else {
            validWordList = []
        }

        decomposedWordList = validWordList.map { Jamo.decompose($0) }
        resetGame()
    }

    func resetGame() {
        currentInput = []
        attempts = []
        isGameOver = false
        didWin = false
        errorMessage = nil
        keyboardColors = [:]
        answer = []

        while answer.count != 6 {
            var rng = SystemRandomNumberGenerator()
            rawAnswer = answerPool.randomElement(using: &rng) ?? ""
            let decomposed = Jamo.decompose(rawAnswer).map { String($0) }
            
            if decomposed.count == 6 {
                answer = decomposed
                break
            }
        }
        
        print("정답(자모):", answer)
    }

    func addJamo(_ jamo: String) {
        errorMessage = nil
        guard !isGameOver else { return }
        guard currentInput.count < 6 else { return }
        currentInput.append(jamo)
    }

    func removeLast() {
        if !currentInput.isEmpty {
            errorMessage = nil
            currentInput.removeLast()
        }
    }

    func submit() {
        guard currentInput.count == 6 else {
            errorMessage = "자모 6개를 입력해주세요!"
            return
        }

        // 조합한 단어 유효성 검사
//        let input = normalizeDoubleConsonants(currentInput)
        if !isValidJamoWord(currentInput) {
            errorMessage = "존재하지 않는 단어예요!"
            currentInput = []
            return
        }

        print("입력값: \(currentInput)")
        
        let result = compare(input: currentInput, answer: answer)
        attempts.append(result)

        for tile in result {
            let existing = keyboardColors[tile.character]
            switch (existing, tile.color) {
            case (_, .blue):
                keyboardColors[tile.character] = .blue
            case (.blue, _):
                continue
            case (_, .lightBlue):
                keyboardColors[tile.character] = .lightBlue
            case (nil, .gray):
                keyboardColors[tile.character] = .gray
            default:
                continue
            }
        }

        currentInput = []

        if result.allSatisfy({ $0.color == .blue }) {
            isGameOver = true
            didWin = true
        } else if attempts.count >= maxAttempts {
            isGameOver = true
            didWin = false
        }
    }

    private func compare(input: [String], answer: [String]) -> [JamoTile] {
        var result: [JamoTile] = []
        var remainingAnswer = answer

        for i in 0..<input.count {
            let inputChar = input[i]
            if inputChar == answer[i] {
                result.append(JamoTile(character: inputChar, color: .blue))
                remainingAnswer[i] = "✓" // mark used
            } else {
                result.append(JamoTile(character: inputChar, color: .gray))
            }
        }

        for i in 0..<input.count {
            if result[i].color == .gray, let idx = remainingAnswer.firstIndex(of: input[i]) {
                result[i].color = .lightBlue
                remainingAnswer[idx] = "✓"
            }
        }

        return result
    }

    private func isValidJamoWord(_ input: [String]) -> Bool {
        return decomposedWordList.contains { $0 == input }
    }
    
    /// 입력된 자모 배열에서 쌍초성으로 바꿔주는 정규화 함수
    func normalizeDoubleConsonants(_ input: [String]) -> [String] {
        var result: [String] = []
        var i = 0

        let doubles: [String: String] = [
            "ㄱㄱ": "ㄲ",
            "ㄷㄷ": "ㄸ",
            "ㅂㅂ": "ㅃ",
            "ㅅㅅ": "ㅆ",
            "ㅈㅈ": "ㅉ"
        ]

        while i < input.count {
            if i + 1 < input.count {
                let pair = input[i] + input[i + 1]
                if let double = doubles[pair] {
                    result.append(double)
                    i += 2
                    continue
                }
            }
            result.append(input[i])
            i += 1
        }

        return result
    }
}

import UIKit

extension GameViewModel {
    func copyResultToClipboard() {
        var result = "🍚꼬들밥🍚 \(attempts.count)회 만에 성공!✨\n\n"

        for attempt in attempts {
            for tile in attempt {
                switch tile.color {
                case .blue:
                    result += "💙"
                case .lightBlue:
                    result += "🩵"
                case .gray:
                    result += "🤍"
                }
            }
            result += "\n"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy년 M월 d일 (E) a h시 m분"

        let dateString = formatter.string(from: Date())
        result += "\n\(dateString)"
        UIPasteboard.general.string = result
    }
}
