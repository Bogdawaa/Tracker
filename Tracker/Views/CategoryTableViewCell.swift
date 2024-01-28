//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 23.01.2024.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    static let identifier = "categoryCell"
    
    let titleLabel: UILabel = UILabel()
    
    var categoryViewModel: TrackerCategory! {
        didSet {
            titleLabel.text = categoryViewModel.category
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .ypGray
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
