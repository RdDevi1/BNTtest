//
//  ModuleBuiler.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 17.01.2024.
//

import Foundation

enum Service {
    case router, moduleBuilder, networkService
}

protocol ServiceProtocol: CustomStringConvertible {}

protocol ServiceObtainableProtocol {
    var neededServices: [Service] { get }
    func getServices(_ services: [Service: ServiceProtocol])
}

// MARK: - ModuleBuilder

protocol ModuleBuilderProtocol {
    func createListModule() -> DrugsListViewController
    func createItemDetailModule(drug: Drug) -> DrugItemViewController
}


final class ModuleBuilder: ModuleBuilderProtocol {
    private var services: [Service: ServiceProtocol] = [:]

    init() {
        services[.networkService] = NetworkService()
        services[.moduleBuilder] = self

        let router = Router()
        injectServices(forObject: router)
        services[.router] = router
    }

    private func injectServices(forObject object: ServiceObtainableProtocol) {
        let neededServices = object.neededServices
        let servicesDict = neededServices.reduce(into: [:]) { dict, service in
            dict[service] = services[service]
        }
        object.getServices(servicesDict)
    }

    func getRouter() -> Router? {
        return services[.router] as? Router
    }

    func createListModule() -> DrugsListViewController {
        let view = DrugsListViewController()
        let presenter = DrugsListPresenter(view: view)
        injectServices(forObject: presenter)
        view.presenter = presenter

        return view
    }

    func createItemDetailModule(drug: Drug) -> DrugItemViewController {
        let view = DrugItemViewController()
        let presenter = DrugItemPresenter(view: view, drug: drug)
        injectServices(forObject: presenter)
        view.presenter = presenter

        return view
    }
}

// MARK: - ServiceProtocol
extension ModuleBuilder: ServiceProtocol {
    var description: String {
        return "ModuleBuilder"
    }
}
