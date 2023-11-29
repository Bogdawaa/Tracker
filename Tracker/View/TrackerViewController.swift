//
//  ViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 24.11.2023.
//

import UIKit

class TrackerViewController: UIViewController {
    
    // MARK: - private properties
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.placeholder = "Поиск"
        sc.obscuresBackgroundDuringPresentation  = false
        return sc
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        let btn = UIBarButtonItem()
        btn.image = UIImage(named: "addButton")
        btn.style = .plain
        btn.target = nil
        btn.tintColor = .black
        btn.action = #selector(addButtonAction)
        return btn
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        return dp
    }()
    
    private lazy var emptyTrackresView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyTrackersLogo: UIImageView = {
        let iv = UIImageView()
        let img = UIImage(named: "error")
        iv.image = img
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var emptyTrackersLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Что будем отслеживать?"
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .ypBlack
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    // MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .white
        emptyTrackresView.addSubview(emptyTrackersLogo)
        emptyTrackresView.addSubview(emptyTrackersLabel)
        view.addSubview(emptyTrackresView)
        applyConstraints()
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "Трекеры"
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        self.navigationItem.searchController = searchController
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
    }
    
    private func applyConstraints() {
        let emptyTrackresViewConstraints = [
            emptyTrackresView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyTrackresView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            emptyTrackresView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            emptyTrackresView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ]
        
        let emptyTrackersLogoConstrains = [
            emptyTrackersLogo.heightAnchor.constraint(equalToConstant: 80),
            emptyTrackersLogo.widthAnchor.constraint(equalToConstant: 80),
            emptyTrackersLogo.centerXAnchor.constraint(equalTo: emptyTrackresView.centerXAnchor),
            emptyTrackersLogo.centerYAnchor.constraint(equalTo: emptyTrackresView.centerYAnchor)
        ]
        let emptyTrackersLabelConstraints = [
            emptyTrackersLabel.centerXAnchor.constraint(equalTo: emptyTrackresView.centerXAnchor),
            emptyTrackersLabel.topAnchor.constraint(equalTo: emptyTrackersLogo.bottomAnchor, constant: 8)
        ]
        NSLayoutConstraint.activate(emptyTrackresViewConstraints)
        NSLayoutConstraint.activate(emptyTrackersLogoConstrains)
        NSLayoutConstraint.activate(emptyTrackersLabelConstraints)
    }
    
    // MARK: - actions
    @objc func addButtonAction() {
        // TODO: реализовать добавление карточек привычек
    }
}

extension TrackerViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // todo
    }
}
