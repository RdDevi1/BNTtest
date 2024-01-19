//
//  DrugsListViewController.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 15.01.2024.
//

import UIKit

final class DrugsListViewController: UIViewController {
    // MARK: - UI-elements
    private lazy var searchButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image:  UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(didTapOnSearchButton)
        )
        button.tintColor = .white
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.showsCancelButton = false
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        view.register(
            DrugCell.self,
            forCellWithReuseIdentifier: DrugCell.reuseIdentifier
        )
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Properties
    var presenter: DrugsListPresenterProtocol!
    var collectionIsWaitingForUpdate: Bool = false
    var timer: Timer!
    private let collectionParams = UICollectionView.CollectionParams(
            cellCount: 2,
            leftInset: 16,
            rightInset: 16,
            topInset: 15,
            bottomInset: 15,
            height: 296,
            cellSpacing: 15
        )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    deinit {
        print("deinited DrugsListViewController")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupConstraints()
    }
    
    // MARK: - Methods
    func setupUI() {
        view.backgroundColor = .white
        title = "Препараты"
        [collectionView].forEach {
            view.addSubview($0)
        }
        navigationItem.rightBarButtonItem = searchButton
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view)
        }
    }
    
    // MARK: - Actions
    @objc func didTapOnSearchButton(_ sender: UIBarButtonItem) {
        searchBar.delegate = self
        navigationItem.setRightBarButton(nil, animated: true)
        navigationItem.titleView = searchBar
        collectionView.setContentOffset(.zero, animated: true)
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        if searchBar.isFirstResponder {
//            searchBar.resignFirstResponder()
//        }
//    }
}

// MARK: - DrugsListViewProtocol
extension DrugsListViewController: DrugsListViewProtocol {
    func reloadItem(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        DispatchQueue.main.async {
            print("reloading item \(index)")
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func addItemsAt(_ indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.collectionView.insertItems(at: indexPaths)
            print("items inserted")
            if indexPaths.count == 10 {
                self.collectionIsWaitingForUpdate = false
            }
        }
    }
    
    func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.collectionView.isDecelerating || self.collectionView.isDragging {
                
            }
            self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DrugsListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrugCell.reuseIdentifier, for: indexPath) as! DrugCell
        guard let drug = presenter.requestDataForItem(at: indexPath) else {
            return cell
        }
        cell.configure(with: drug)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DrugsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didTapOnItem(at: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !collectionIsWaitingForUpdate else {
            return
        }
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height {
            print("new batch of items is requested")
            presenter.requestNetSetOfItems(text: searchBar.text ?? "")
            collectionIsWaitingForUpdate = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableSpace = collectionView.frame.width - collectionParams.paddingWidth
        let cellWidth = availableSpace / collectionParams.cellCount
        return CGSize(width: cellWidth, height: collectionParams.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: collectionParams.topInset,
            left: collectionParams.leftInset,
            bottom: collectionParams.bottomInset,
            right: collectionParams.rightInset
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        collectionParams.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        collectionParams.cellSpacing
    }
}

// MARK: - UISearchBarDelegate
extension DrugsListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            searchBar.text = ""
            searchBar.delegate?.searchBar?(searchBar, textDidChange: "")
        }
        searchBar.setShowsCancelButton(false, animated: true)
        navigationItem.titleView = nil
        navigationItem.rightBarButtonItem = searchButton
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        тут таймер потому, что не хочется на каждое изменение слова !сразу! дулать запросы. Пусть юзер введет хоть что-то более менее завершенное.
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        timer = Timer(timeInterval: 0.2, repeats: false, block: { [weak self] _ in
            self?.presenter.requestNetSetOfItems(text: searchText)
            self?.timer.invalidate()
            self?.timer = nil
        })
        timer.tolerance = 0.02
        RunLoop.current.add(timer, forMode: .common)
    }
}

