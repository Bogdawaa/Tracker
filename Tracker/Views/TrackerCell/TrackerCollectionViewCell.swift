//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 06.12.2023.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completedTracker(id: UUID, at indexPath: IndexPath)
    func uncompletedTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - public properties
    weak var cellDelegate: TrackerCellDelegate?
    
    static let identifier = "TrackerCell"
    
    private var completedDaysLocalized: String = ""
    
    let emojiContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 11
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var textLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let counterLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "0 дней"
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .ypBlack
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let completeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "btnToCompleteTracker"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 17
        btn.tintColor = .white
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(completeButtonDidTap), for: .touchUpInside)
        return btn
    }()

    
    // MARK: - private properties
    private var counter: Int = 0
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    private var isCompletedToday: Bool = false
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .ypRed
        containerView.layer.masksToBounds = true

        containerView.addSubview(emojiContainerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(textLabel)
        contentView.addSubview(containerView)
        contentView.addSubview(counterLabel)
        contentView.addSubview(completeButton)

        applyConstraints()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let uiColorMarshalling = UIColorMarshalling()
    
    func updateCell(
        with tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        self.containerView.backgroundColor = tracker.color
        self.completeButton.backgroundColor = tracker.color
        
        self.textLabel.text = tracker.name
        self.emojiLabel.text = tracker.emoji
        self.counterLabel.text = pluralizeDays(completedDays)
        
        if isCompletedToday == true {
            completeButton.setImage(UIImage(named: "btnCompletedTracker"), for: .normal)
        } else {
            completeButton.setImage(UIImage(named: "btnToCompleteTracker"), for: .normal)
        }
    }
    
    //MARK: - private methods
    private func applyConstraints() {
        let containerViewConstraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 90)
        ]
        let emojiContainerConstraints = [
            emojiContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiContainerView.widthAnchor.constraint(equalToConstant: 24),
            emojiContainerView.heightAnchor.constraint(equalToConstant: 24),
        ]
        let emojiLabelConstraints = [
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainerView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainerView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 22)
        ]
        let textLabelConstraints = [
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
        ]
        let counterLabelConstraints = [
            counterLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
        ]
        let completeBtnConstraints = [
            completeButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ]
        NSLayoutConstraint.activate(containerViewConstraints)
        NSLayoutConstraint.activate(emojiContainerConstraints)
        NSLayoutConstraint.activate(emojiLabelConstraints)
        NSLayoutConstraint.activate(textLabelConstraints)
        NSLayoutConstraint.activate(counterLabelConstraints)
        NSLayoutConstraint.activate(completeBtnConstraints)
    }
    
    private func pluralizeDays(_ count: Int) -> String {
        completedDaysLocalized = String.localizedStringWithFormat(
            NSLocalizedString("number_of_days", comment: "Number of days with completed Tracker"),
            count
        )
        return completedDaysLocalized
    }
    
    // MARK: - actions
    @objc func completeButtonDidTap() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("no tracker id, indexPAth")
            return
        }
        if isCompletedToday {
            cellDelegate?.uncompletedTracker(id: trackerId, at: indexPath)
        } else {
            cellDelegate?.completedTracker(id: trackerId, at: indexPath)
        }
    }
}

extension TrackerCollectionViewCell {
    var highlightView: UIView {
        return containerView
    }
}
