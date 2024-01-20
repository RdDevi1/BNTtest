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
        
        guard let router = moduleBuilder.getRouter() else {
            print("Error while getting router")
            return
        }
        
        let listVC = moduleBuilder.createListModule()
        let navigationController = NavigationController(rootViewController: listVC)
        
        router.window = window
        router.navigation = navigationController
        router.showListModule()
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

}
