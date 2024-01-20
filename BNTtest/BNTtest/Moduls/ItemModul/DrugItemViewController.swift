//
//  DrugItemViewController.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 17.01.2024.
//

import UIKit
import SnapKit
import Kingfisher

final class DrugItemViewController: UIViewController {
    // MARK: - UI-elements
    private lazy var mainImageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var categoryIconImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var addFavoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .yellow
        return button
    }()
    
    private lazy var drugNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var drugDetailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var whereToBuyButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.937, green: 0.937, blue: 0.941, alpha: 1).cgColor
        button.setTitle("ГДЕ КУПИТЬ", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(named: "LocationIcon"), for: .normal)
//        button.imageEdgeInsets = UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 7)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    // MARK: - Properties
    var presenter: DrugItemPresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.requestDataUpdate()
        presenter?.getCategoryIcon()
    }
    
    deinit {
        print("deinited ItemDetailViewController")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpConstraints()
    }
    
    // MARK: - Methods
    private func setupUI() {
        view.backgroundColor = .white
        [mainImageView, categoryIconImageView, addFavoriteButton, drugNameLabel, drugDetailLabel, whereToBuyButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        mainImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.centerX.equalTo(view.snp.centerX)
            make.height.equalTo(view.frame.width / 2)
            make.width.equalTo(view.frame.width / 3)
        }
        
        categoryIconImageView.snp.makeConstraints { make in
            make.height.width.equalTo(32)
            make.leading.equalTo(view.snp.leading).offset(34)
            make.top.equalTo(mainImageView.snp.top)
        }
        
        addFavoriteButton.snp.makeConstraints { make in
            make.height.width.equalTo(32)
            make.trailing.equalTo(view.snp.trailing).offset(-34)
            make.top.equalTo(mainImageView.snp.top)
        }
        
        drugNameLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImageView.snp.bottom).offset(32)
            make.leading.equalTo(view.snp.leading).offset(14)
            make.trailing.equalTo(view.snp.trailing).offset(-14)
        }
        
        drugDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(drugNameLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.snp.leading).offset(14)
            make.trailing.equalTo(view.snp.trailing).offset(-14)
        }
        
        whereToBuyButton.snp.makeConstraints { make in
            make.top.equalTo(drugDetailLabel.snp.bottom).offset(16)
            make.centerX.equalTo(view.snp.centerX)
            make.leading.equalTo(view.snp.leading).offset(14)
            make.trailing.equalTo(view.snp.trailing).offset(-14)
            make.height.equalTo(36)
        }
    }
}

extension DrugItemViewController: ItemDetailViewProtocol {
    func updateUIUsing(_ drug: Drug) {
        drugNameLabel.text = drug.name
        drugDetailLabel.text = drug.description
        guard
            let image = drug.imageURL,
            let urlImage = URL(string: image)
        else {
            return mainImageView.image =  UIImage(systemName: "photo")
        }
        mainImageView.kf.setImage(with: urlImage)
    }
    
    func updateCategoriesIcon(_ iconUrl: String) {
        var iconImage: UIImage!
        
        guard let iconURL = URL(string: iconUrl) else {
            print("Can not create image URL")
            iconImage = UIImage(named: "noImage")
            return
        }
        do {
            let data = try Data(contentsOf: iconURL)
            if let image = UIImage(data: data) {
                iconImage = image
            }
        } catch {
            print("No image for item")
            iconImage = UIImage(named: "noImage")
        }
        
        DispatchQueue.main.async {
            self.categoryIconImageView.image = iconImage
        }
    }
}

