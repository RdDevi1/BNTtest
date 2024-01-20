//
//  Router.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 15.01.2024.
//

import UIKit

protocol RouterProtocol {
    var window: UIWindow? { get }

    func showListModule()
    func showItemDetailModule(drug: Drug)
}

final class Router: RouterProtocol, ServiceObtainableProtocol {
    
    weak var window: UIWindow?
    var navigation: NavigationController?
    
    var moduleBuilder: ModuleBuilderProtocol?

    var neededServices: [Service] {
        return [.moduleBuilder]
    }

    func getServices(_ services: [Service: ServiceProtocol]) {
        self.moduleBuilder = services[.moduleBuilder] as? ModuleBuilderProtocol
    }

    func showListModule() {
        guard let navigation = self.navigation else {
            let listVC = moduleBuilder?.createListModule()
            self.navigation = NavigationController(rootViewController: listVC!)
            print("ListModule created")
            return
        }

        window?.rootViewController = navigation
        print("ListModule shown")
    }

    func showItemDetailModule(drug: Drug) {
        guard let navigation = self.navigation, let detailVC = moduleBuilder?.createItemDetailModule(drug: drug) else {
            print("Error while showing ItemDetailModule")
            return
        }

        navigation.pushViewController(detailVC, animated: true)
        print("ItemDetailModule shown")
    }
}

    // MARK: - ServiceProtocol
extension Router: ServiceProtocol {
    var description: String {
        return "Router"
    }
}
