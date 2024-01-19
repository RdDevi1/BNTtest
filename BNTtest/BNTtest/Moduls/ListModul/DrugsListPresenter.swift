//
//  DrugsListPresenter.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 16.01.2024.
//

import Foundation

protocol DrugsListViewProtocol: AnyObject {
    var presenter: DrugsListPresenterProtocol! { get }
    
    func addItemsAt(_ indexPaths: [IndexPath])
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
    var router: RouterProtocol?
    var networkService: NetworkServiceProtocol?
    
    private var drugs: [Drug] = []
    private var lastRequest: String = ""
    private let lock = NSLock()
    
    weak var view: DrugsListViewProtocol!
    
    // MARK: - LifeCycle
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
                    self.view.addItemsAt(indexPaths)
                }
                self.loadImages()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadImages() {
        for (index, drug) in drugs.enumerated() {
            networkService?.downloadImageFor(drug: drug) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let imageUrl):
                    guard index < self.drugs.count else { return }
                    self.drugs[index].imageURL = imageUrl.absoluteString
                    self.view.reloadItem(at: index)
                case .failure:
                    break
                }
            }
        }
    }
    
    func getNumberOfItems() -> Int {
        return drugs.count
    }
    
    func requestDataForItem(at indexPath: IndexPath) -> Drug? {
        return drugs[indexPath.item]
    }
    
    func didTapOnItem(at indexPath: IndexPath) {
        router?.showItemDetailModule(drug: drugs[indexPath.item])
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
