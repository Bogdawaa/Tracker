//
//  SupplementaryEmojiView.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 12.12.2023.
//

import UIKit

class SupplementaryEmojiView: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Header"
        lbl.font = .systemFont(ofSize: 19, weight: .bold)
        lbl.textColor = .ypBlack
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant:  -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
