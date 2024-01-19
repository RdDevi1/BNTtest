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

final class Router: RouterProtocol {
    weak var window: UIWindow?
    private var navigation: NavigationController?
    
    var moduleBuilder: ModuleBuilderProtocol?
    
    func showListModule() {
        if navigation != nil {
            window?.rootViewController = navigation
            print("showing ListModule")
        } else if let listVC = moduleBuilder?.createListModule() {
            navigation = NavigationController(rootViewController: listVC)
            print("created ListModule")
            showListModule()
        } else { print("Error while creating ListModule") }
    }
    
    func showItemDetailModule(drug: Drug) {
        if navigation == nil {
            print("somehow ItemDetailModule precedes ListModule")
            showListModule()
            showItemDetailModule(drug: drug)
        } else if let detailVC = moduleBuilder?.createItemDetailModule(drug: drug) {
            navigation?.pushViewController(detailVC, animated: true)
            print("showing ItemDetailModule")
        } else {
            print("Error while showing ItemDetailModule")
        }
    }
}

extension Router: ServiceProtocol {
    var description: String {
        return "Router"
    }
}

extension Router: ServiceObtainableProtocol {
    var neededServices: [Service] {
        return  [.moduleBuilder]
    }
    
    func getServices(_ services: [Service : ServiceProtocol]) {
        self.moduleBuilder = (services[.moduleBuilder] as! ModuleBuilderProtocol)
    }
}

