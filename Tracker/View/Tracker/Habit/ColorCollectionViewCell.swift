//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 13.12.2023.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    static let identifier = "colorCell"
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(color: UIColor) {
        self.colorView.backgroundColor = color
    }
    
    //MARK: - private methods
    private func applyConstraints() {
        let colorViewConstraints = [
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(colorViewConstraints)
    }
}

