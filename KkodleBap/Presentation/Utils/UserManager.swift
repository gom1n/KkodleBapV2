//
//  UserManager.swift
//  KkodleBap
//
//  Created by gomin on 8/23/25.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    var container: UserDefaults = .standard

    var wrappedValue: T {
        get { container.object(forKey: key) as? T ?? defaultValue }
        set { container.set(newValue, forKey: key) }
    }
}

enum UserManager {
    @UserDefault(key: "user.mapVersion", defaultValue: 6)
    static var mapVersion: Int

    @UserDefault(key: "user.username", defaultValue: "")
    static var username: String

    static func resetAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "user.mapVersion")
        defaults.removeObject(forKey: "user.username")
    }
}
