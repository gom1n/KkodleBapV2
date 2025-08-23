//
//  UserManager.swift
//  KkodleBap
//
//  Created by gomin on 8/23/25.
//

import Foundation
import Combine

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    var container: UserDefaults = .standard
    
    private let subject: CurrentValueSubject<T, Never>
    
    init(key: String, defaultValue: T, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
        let value = container.object(forKey: key) as? T ?? defaultValue
        self.subject = CurrentValueSubject<T, Never>(value)
    }
    
    var wrappedValue: T {
        get { container.object(forKey: key) as? T ?? defaultValue }
        set {
            container.set(newValue, forKey: key)
            subject.send(newValue)   // 🔥 값 바뀌면 퍼블리셔도 발행
        }
    }
    
    var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }
}

enum UserManager {
    @UserDefault(key: "user.mapVersion", defaultValue: 6)
    static var mapVersion: Int
    
    @UserDefault(key: "user.bap", defaultValue: 0)
     static var bap: Int
    
    @UserDefault(key: "user.bappool", defaultValue: 0)
    static var bappool: Int

    @UserDefault(key: "user.username", defaultValue: "")
    static var username: String

    static func resetAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "user.mapVersion")
        defaults.removeObject(forKey: "user.username")
    }
}
