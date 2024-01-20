//
//  DrugsListPresenter.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 16.01.2024.
//

import Foundation

protocol DrugsListViewProtocol: AnyObject {
    var presenter: DrugsListPresenterProtocol! { get }
    
    func addItems(at indexPaths: [IndexPath])
    func reloadItem(at index: Int)
    func reloadCollection()
}

protocol DrugsListPresenterProtocol {
    func requestNetSetOfItems(text: String)
    func getNumberOfItems() -> Int
    func requestDataForItem(at indexPath: IndexPath) -> Drug?
    func didTapOnItem(at indexPath: IndexPath)
}

final class DrugsListPresenter: DrugsListPresenterProtocol {
    weak var view: DrugsListViewProtocol!
    
    var router: RouterProtocol?
    var networkService: NetworkServiceProtocol?
    
    private var drugs: [Drug] = []
    private var lastRequest: String = ""

    init(view: DrugsListViewProtocol) {
        self.view = view
    }
    
    func requestNetSetOfItems(text: String) {
        let nextBatchStartIndex = lastRequest == text ? drugs.count : 0
        networkService?.getItemsOn(query: text, startingFrom: nextBatchStartIndex, amount: 10) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let items):
                if self.lastRequest != text {
                    self.drugs = items
                    self.view.reloadCollection()
                    self.lastRequest = text
                } else {
                    self.drugs.append(contentsOf: items)
                    let indexPaths = (nextBatchStartIndex ..< self.drugs.count).map { IndexPath(item: $0, section: 0) }
                    self.view.addItems(at: indexPaths)
                }
                self.loadImages()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadImages() {
        drugs.enumerated().forEach { index, drug in
            networkService?.downloadImageFor(drug: drug) { [weak self] result in
                guard let self = self, case .success(let imageUrl) = result, index < self.drugs.count else { return }
                
                self.drugs[index].imageURL = imageUrl.absoluteString
                self.view.reloadItem(at: index)
            }
        }
    }
    
    func getNumberOfItems() -> Int {
        return drugs.count
    }
    
    func requestDataForItem(at indexPath: IndexPath) -> Drug? {
        return drugs.element(at: indexPath.item)
    }
    
    func didTapOnItem(at indexPath: IndexPath) {
        if let selectedDrug = drugs.element(at: indexPath.item) {
            router?.showItemDetailModule(drug: selectedDrug)
        }
    }
}

// MARK: - ServiceObtainableProtocol
extension DrugsListPresenter: ServiceObtainableProtocol {
    var neededServices: [Service] {
        [.router, .networkService]
    }
    
    func getServices(_ services: [Service : ServiceProtocol]) {
        self.router = services[.router] as? RouterProtocol
        self.networkService = services[.networkService] as? NetworkServiceProtocol
    }
}

// Helper extension to safely access array elements
extension Array {
    func element(at index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
