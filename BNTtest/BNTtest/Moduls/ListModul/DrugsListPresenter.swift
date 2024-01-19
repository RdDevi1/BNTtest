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
    
    var lock = pthread_rwlock_t()
    var attr = pthread_rwlockattr_t()
    var drugs: [Drug] {
        get {
            pthread_rwlock_rdlock(&lock)
            let tmp = itemsArr
            pthread_rwlock_unlock(&lock)
            return tmp
        }
        set {
            pthread_rwlock_wrlock(&lock)
            itemsArr = newValue
            pthread_rwlock_unlock(&lock)
        }
    }
    
    private var itemsArr: [Drug] = []
    var lastRequest: String = ""
    weak var view: DrugsListViewProtocol!
    
    // MARK: - LifeCycle
    init(view: DrugsListViewProtocol) {
        self.view = view
        pthread_rwlock_init(&lock, &attr)
    }
    deinit {
        print("deinited ListPresenter")
    }
    
    func requestNetSetOfItems(text: String) {
        let nextBatchStartIndex = lastRequest == text ? drugs.count : 0
        networkService?.getItemsOn(query: text,
                                   startingFrom: nextBatchStartIndex,
                                   amount: 10,
                                   completion: { result in
            switch result {
            case .success(let items):
                if self.lastRequest != text {
                    self.drugs = items
                    self.view.reloadCollection()
                    self.lastRequest = text
                } else {
                    self.drugs.append(contentsOf: items)
                    var indexPaths: [IndexPath] = []
                    (nextBatchStartIndex ..< self.drugs.count).forEach { index in
                        indexPaths.append(.init(item: index, section: 0))
                    }
                    self.view.addItemsAt(indexPaths)
                }
                self.loadImages()
            case .failure(let error):
                print(error.localizedDescription)
                return
            }
        })
    }
    
    private func loadImages() {
        for (index, drug) in drugs.enumerated() {
            networkService?.downloadImageFor(drug: drug,
                                             completion: { result in
                switch result {
                case .success(let imageUrl):
                    guard index < self.drugs.count else {
                        return
                    }
                    self.drugs[index].imageURL = imageUrl.absoluteString
                    self.view.reloadItem(at: index)
                case .failure(_):
                    return
                }
            })
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
        self.router = (services[.router] as! RouterProtocol)
        self.networkService = (services[.networkService] as! NetworkServiceProtocol)
    }
}
