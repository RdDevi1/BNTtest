//
//  DrugCell.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 16.01.2024.
//

import UIKit
import SnapKit
import Kingfisher

final class DrugCell: UICollectionViewCell {
    // MARK: - UI-elements
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 8
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(red: 0.683, green: 0.691, blue: 0.712, alpha: 1)
        view.font = UIFont(name: "SFProDisplay-Medium", size: 12)
        view.numberOfLines = 5
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = ""
        descriptionLabel.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
    
    // MARK: - Layout methods
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.2
        [imageView, nameLabel, descriptionLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(12)
            make.top.equalTo(contentView).offset(12)
            make.trailing.equalTo(contentView).offset(-12)
            make.height.equalTo(82)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(12)
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.trailing.equalTo(contentView).offset(-12)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(12)
            make.trailing.equalTo(contentView).offset(-12)
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.bottom.equalTo(contentView).offset(-12)
        }
    }
    
    func configure(with drug: Drug) {
        imageView.backgroundColor = .systemGray
        nameLabel.text = drug.name
        descriptionLabel.text = drug.description
        guard
            let image = drug.imageURL,
            let urlImage = URL(string: image)
        else {
            return imageView.image =  UIImage(systemName: "photo")
        }
        imageView.kf.setImage(with: urlImage)
    }
}

// MARK: - Reusable
extension DrugCell: Reusable {}
