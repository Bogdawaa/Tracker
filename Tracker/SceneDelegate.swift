//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 24.11.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        
        let onboardingWasShown = UserDefaults.standard.getOnboardingWasShown()
        if onboardingWasShown == false {
            window?.rootViewController = OnboardingViewController()
        } else {
            window?.rootViewController = TabBarController()
        }
        window?.makeKeyAndVisible()
    }
}

