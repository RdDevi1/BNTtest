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
        
        let drugsListViewController = DrugsListViewController()
        let viewModel = DrugsListViewModel()
        drugsListViewController.viewModel = viewModel
        let navigationController = UINavigationController(rootViewController: drugsListViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}