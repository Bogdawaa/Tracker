//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 12.12.2023.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    static let identifier = "EmojiCell"
    
    private lazy var emojiLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "123"
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.backgroundColor = .clear
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiLabel)
        contentView.backgroundColor = .clear
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(emoji: String) {
        self.emojiLabel.text = emoji
    }
    
    //MARK: - private methods
    private func applyConstraints() {
        let emojiLabelConstraints = [
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            emojiLabel.heightAnchor.constraint(equalToConstant: 52)
        ]
        NSLayoutConstraint.activate(emojiLabelConstraints)
    }
}
