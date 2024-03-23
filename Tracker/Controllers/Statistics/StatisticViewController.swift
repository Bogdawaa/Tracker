//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 26.11.2023.
//

import UIKit

protocol StatisticsVCDelegate: AnyObject {
    func updateStatisticsView()
}

class StatisticViewController: UIViewController, StatisticsVCDelegate {

    private let trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    private var completedTrackersTotal = StatisticsCardView()

    private lazy var statisticsNotFoundImage: UIImageView = {
        let iv = UIImageView()
        let img = UIImage(named: "statisticsNotFound")
        iv.image = img
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var statisticsNotFoundLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "statisticsNotFoundLabel".localized
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .ypBlack
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var statisticsNotFoundView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statisticsCardView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let gradientColors = [
        UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1),
        UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1),
        UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1)
    ]
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatisticsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatisticView()
        applyConstraints()
        updateStatisticsView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statisticsCardView.setGradientBorder(width: 1.0, colors: gradientColors)
    }
    
    func updateStatisticsView() {
        guard let completedTrackers = try? trackerRecordStore.fetchRecords().count else { return }
        
        if completedTrackers > 0 {
            completedTrackersTotal.setupStatisticsCardView(
                title: String(completedTrackers),
                subtitle: "Трекеров завершено"
            )
            statisticsNotFoundView.isHidden = true
            statisticsCardView.isHidden = false
        } else {
            statisticsNotFoundView.isHidden = false
            statisticsCardView.isHidden = true
        }
    }
    
    private func setupStatisticView() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "statisticsTitleLabel".localized
        statisticsNotFoundView.addSubview(statisticsNotFoundImage)
        statisticsNotFoundView.addSubview(statisticsNotFoundLabel)
        view.addSubview(statisticsNotFoundView)
        statisticsCardView.addSubview(completedTrackersTotal)
        view.addSubview(statisticsCardView)
    }
    
    private func applyConstraints() {
        let statisticsNotFoundViewConstraints = [
            statisticsNotFoundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsNotFoundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statisticsNotFoundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statisticsNotFoundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        let statisticsCardViewConstraints = [
            statisticsCardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            statisticsCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticsCardView.heightAnchor.constraint(equalToConstant: 90)
        ]
        let statisticsNotFoundImageConstraints = [
            statisticsNotFoundImage.widthAnchor.constraint(equalToConstant: 80),
            statisticsNotFoundImage.heightAnchor.constraint(equalToConstant: 80),
            statisticsNotFoundImage.centerXAnchor.constraint(equalTo: statisticsNotFoundView.centerXAnchor),
            statisticsNotFoundImage.centerYAnchor.constraint(equalTo: statisticsNotFoundView.centerYAnchor)
        ]
        let statisticsNotFoundLabelConstraints = [
            statisticsNotFoundLabel.topAnchor.constraint(equalTo: statisticsNotFoundImage.bottomAnchor, constant: 8),
            statisticsNotFoundLabel.centerXAnchor.constraint(equalTo: statisticsNotFoundView.centerXAnchor)
        ]
        NSLayoutConstraint.activate(statisticsNotFoundViewConstraints)
        NSLayoutConstraint.activate(statisticsNotFoundImageConstraints)
        NSLayoutConstraint.activate(statisticsNotFoundLabelConstraints)
        NSLayoutConstraint.activate(statisticsCardViewConstraints)
    }
}
