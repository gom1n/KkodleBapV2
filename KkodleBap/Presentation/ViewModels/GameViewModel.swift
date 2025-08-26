//
//  GameViewModel.swift
//  KkodleBap
//
//  Created by gomin on 8/7/25.
//

import Foundation
import UIKit

struct JamoTile: Identifiable, Hashable {
    let id = UUID()
    let character: String
    var color: TileColor = .default
}

class GameViewModel: ObservableObject {
    @Published var currentInput: [String] = []
    @Published var attempts: [[JamoTile]] = []
    @Published var isGameOver = false
    @Published var didWin = false
    @Published var errorMessage: String?
    @Published var keyboardColors: [String: TileColor] = [:]

    // 정답의 자모음 개수
    public var ANSWER_COUNT: Int {
        UserManager.mapVersion
    }
    public var rawAnswer: String = ""
    public var answer: [String] = []
    
    // 게임 최대 횟수
    public let BASE_MAX_ATTEMPTS = 6
    private var BONUS_ATTEMPTS = 0
    public var MAX_ATTEMPTS: Int { BASE_MAX_ATTEMPTS + BONUS_ATTEMPTS }
    
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
        BONUS_ATTEMPTS = 0

        while answer.count != ANSWER_COUNT {
            var rng = SystemRandomNumberGenerator()
            rawAnswer = answerPool.randomElement(using: &rng) ?? ""
            let decomposed = Jamo.decompose(rawAnswer).map { String($0) }
            
            if decomposed.count == ANSWER_COUNT {
                answer = decomposed
                break
            }
        }
        
        print("정답(자모):", answer)
    }

    func addJamo(_ jamo: String) {
        errorMessage = nil
        guard !isGameOver else { return }
        guard currentInput.count < ANSWER_COUNT else { return }
        currentInput.append(jamo)
    }

    func removeLast() {
        if !currentInput.isEmpty {
            errorMessage = nil
            currentInput.removeLast()
        }
    }

    func submit() {
        guard currentInput.count == ANSWER_COUNT else {
            errorMessage = "자모 \(ANSWER_COUNT)개를 입력해주세요!"
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
            case (nil, .default):
                keyboardColors[tile.character] = .default
            default:
                continue
            }
        }

        currentInput = []

        if result.allSatisfy({ $0.color == .blue }) {
            isGameOver = true
            didWin = true
        } else if attempts.count >= MAX_ATTEMPTS {
            isGameOver = true
            didWin = false
        }
    }
    
    func grantOneMoreChanceIfPossible() -> Bool {
        BONUS_ATTEMPTS += 1
        isGameOver = false   // 방금 실패 상태를 되돌리고 계속 진행
        return true
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
                result.append(JamoTile(character: inputChar, color: .default))
            }
        }

        for i in 0..<input.count {
            if result[i].color == .default, let idx = remainingAnswer.firstIndex(of: input[i]) {
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

extension GameViewModel {
    func copyResultToClipboard(_ success: Bool = true) -> String {
        var result = ""
        
        if success {
            result = "🍚꼬들밥🍚 \(attempts.count)회 만에 성공!✨\n\n"
        } else {
            result = "🍚꼬들밥🍚 \(attempts.count)회 시도✨\n\n"
        }

        for attempt in attempts {
            for tile in attempt {
                switch tile.color {
                case .blue:
                    result += "💙"
                case .lightBlue:
                    result += "🩵"
                case .default:
                    result += "🤍"
                case .bonus:
                    result += "💛"
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
        
        return result
    }
}
