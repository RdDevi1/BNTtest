//
//  SceneDelegate.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 13.01.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        let moduleBuilder = ModuleBuilder()
        let router = moduleBuilder.getRouter()
        router.window = window
        router.showListModule()
        window?.makeKeyAndVisible()
    }
}
