//
//  SceneDelegate.swift
//  BRZ
//
//  Created by Miguel Sicart on 28/09/2024.
//

// SceneDelegate.swift

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let introVC = IntroductionViewController()
        let navigationController = UINavigationController(rootViewController: introVC)

        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}

