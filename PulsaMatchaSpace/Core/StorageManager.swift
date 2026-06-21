//
//  StorageManager.swift
//  PulsaMatchaSpace
//

import SwiftUI

final class StorageManager {
    static let shared = StorageManager()

    @AppStorage("pms_user_v1") private var userData: Data?

    private init() {}

    func read() -> User {
        guard let userData else { return User() }
        return (try? JSONDecoder().decode(User.self, from: userData)) ?? User()
    }

    func write(_ user: User) {
        userData = try? JSONEncoder().encode(user)
    }

    func reset() {
        userData = nil
    }
}
