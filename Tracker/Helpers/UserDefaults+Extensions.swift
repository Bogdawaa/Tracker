//
//  UserDefaults+Extensions.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 15.03.2024.
//

import Foundation

fileprivate enum UserDefaultsKeys: String {
    case wasShown = "onboardingWasShown"
}

extension UserDefaults {
    func setOnboardingWasShown(value: Bool) {
        set(value, forKey: UserDefaultsKeys.wasShown.rawValue)
    }
    func getOnboardingWasShown() -> Bool {
        return bool(forKey: UserDefaultsKeys.wasShown.rawValue)
    }
}
