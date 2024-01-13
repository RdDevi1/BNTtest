//
//  TroublesListCell.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 13.01.2024.
//

import UIKit

final class TroublesListCell: UICollectionViewCell {
    // MARK: - Layout
    private let imageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        
        return label
    }()
    
    // MARK: - Properties
    var drug: Drug?
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configure(with drug: Drug) {
        
    }
    
    // MARK: - Layout methods
    func setupView() {
        [imageView, nameLabel].forEach {
            contentView.addSubview($0)
        }
        setConstraints()
    }
    
    func setConstraints() {
        
    }
}

    // MARK: - Reusable
extension TroublesListCell: Reusable {}
