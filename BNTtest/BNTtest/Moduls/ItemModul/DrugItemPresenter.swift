//
//  DrugItemPresenter.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 17.01.2024.
//

import Foundation

protocol ItemDetailViewProtocol: AnyObject {
    var presenter: DrugItemPresenterProtocol? { get }
    
    func updateUIUsing(_ drug: Drug)
    func updateCategoriesIcon(_ iconUrl: String)
}

protocol DrugItemPresenterProtocol {
    func requestDataUpdate()
    func getCategoryIcon()
}

final class DrugItemPresenter: DrugItemPresenterProtocol {
    var router: RouterProtocol?
    var networkService: NetworkServiceProtocol?
    
    weak var view: ItemDetailViewProtocol!
    var drug: Drug!
    
    init(view: ItemDetailViewProtocol, drug: Drug) {
        self.view = view
        self.drug = drug
    }
    deinit {
        print("deinited ItemDetailPresenter")
    }
    
    func requestDataUpdate() {
        view.updateUIUsing(drug)
    }
    
    func getCategoryIcon() {
        networkService?.downloadCategoryIconFor(drug: drug,
                                         completion: { result in
            switch result {
            case .success(let iconUrl):
                self.drug.categories?.icon = iconUrl.absoluteString
                self.view.updateCategoriesIcon(iconUrl.absoluteString)
            case .failure(_):
                return
            }
        })
    }
}

// MARK: - ServiceObtainableProtocol
extension DrugItemPresenter: ServiceObtainableProtocol {
    var neededServices: [Service] {
        [.router, .networkService]
    }
    
    func getServices(_ services: [Service : ServiceProtocol]) {
        self.router = (services[.router] as! RouterProtocol)
        self.networkService = (services[.networkService] as! NetworkServiceProtocol)
    }
}
