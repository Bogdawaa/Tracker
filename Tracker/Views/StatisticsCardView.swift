//
//  StatisticsCardView.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 17.02.2024.
//

import UIKit

class StatisticsCardView: UIView {
    
    private var statisticsCardTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 34, weight: .bold)
        lbl.textColor = .ypBlack
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private var statisticsCardSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .ypBlack
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    init() {
        super.init(frame: .zero)
        addSubview(statisticsCardTitle)
        addSubview(statisticsCardSubtitle)
        applyConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func setupStatisticsCardView(title: String, subtitle: String) {
        statisticsCardTitle.text = title
        statisticsCardSubtitle.text = subtitle
    }
    
    private func applyConstraints() {
        let statisticsCardTitleConstraints = [
            statisticsCardTitle.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            statisticsCardTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
        ]
        let statisticsCardSubtitleConstraints = [
            statisticsCardSubtitle.topAnchor.constraint(equalTo: statisticsCardTitle.bottomAnchor, constant: 7),
            statisticsCardSubtitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
        ]
        NSLayoutConstraint.activate(statisticsCardTitleConstraints)
        NSLayoutConstraint.activate(statisticsCardSubtitleConstraints)
    }
}
