//
//  ViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 24.11.2023.
//

import UIKit

final class TrackerViewController: UIViewController, TrackerVCDelegate {
    
    // MARK: - public properties
    var habitVC: HabitViewController?
    
    // MARK: - private properties
    private var alertPresenter: AlertPresenter?
    private var currentDate: Date?
    private var textFilter: String = ""
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private let trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()
    private let trackerStore: TrackerStoreProtocol = TrackerStore()
    private let trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    private let uicolormarshaling = UIColorMarshalling()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.placeholder = "Поиск"
        sc.obscuresBackgroundDuringPresentation  = false
        sc.hidesNavigationBarDuringPresentation = false
        return sc
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        let btn = UIBarButtonItem()
        btn.image = UIImage(named: "addButton")
        btn.style = .plain
        btn.target = nil
        btn.tintColor = .black
        btn.target = self
        btn.action = #selector(addButtonAction(sender:))
        return btn
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.locale = Locale(identifier: "ru_RU")
        dp.clipsToBounds = true
        dp.layer.cornerRadius = 8
        dp.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        NSLayoutConstraint.activate([dp.widthAnchor.constraint(equalToConstant: 120)])
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
    
    lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 167, height: 148)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        cv.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    
    // MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self

        trackerStore.setDelegate(self)
        alertPresenter = AlertPresenter(viewController: self)
        
        //setup
        updateVisibleCategories()
        setupTabBar()
        setupNavBar()
        setupView()
        setupCollectionView()
        setupSearchController()
        showPlaceholderImage()
        
        view.addHideKeyboardTapGesture()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .white
        emptyTrackresView.addSubview(emptyTrackersLogo)
        emptyTrackresView.addSubview(emptyTrackersLabel)
        view.addSubview(emptyTrackresView)
        view.addSubview(trackersCollectionView)
        applyConstraints()
    }
    
    private func setupTabBar() {
        self.tabBarController?.tabBar.layer.borderWidth = 1
        self.tabBarController?.tabBar.layer.borderColor = UIColor.lightGray.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
    
    private func setupNavBar() {
        navigationItem.title = "Трекеры"
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
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
        let trackersCollectionViewConstraints = [
            trackersCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84)
        ]
        NSLayoutConstraint.activate(emptyTrackresViewConstraints)
        NSLayoutConstraint.activate(emptyTrackersLogoConstrains)
        NSLayoutConstraint.activate(emptyTrackersLabelConstraints)
        NSLayoutConstraint.activate(trackersCollectionViewConstraints)
    }
    
    private func dayOfTheWeek(currentDate: Date) -> String{
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU")
        let index = calendar.component(.weekday, from: currentDate)
        let day = calendar.shortWeekdaySymbols[index-1]
        return day
    }
    
    private func filterVisibleCategories() {
        let dayOfTheWeek = dayOfTheWeek(currentDate: currentDate ?? datePicker.date)
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                return (tracker.schedule.contains(dayOfTheWeek) &&
                        (textFilter.isEmpty || tracker.name.lowercased().contains(textFilter)))
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(
                category: category.category,
                trackers: trackers
            )
        }
        showPlaceholderImage()
        setupCollectionView()
        trackersCollectionView.reloadData()
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(datePicker.date, inSameDayAs: trackerRecord.date)
            return isSameDay && (trackerRecord.id == id)
        }
    }
    
    private func showPlaceholderImage() {
        if (categories.count == 0) {
            self.emptyTrackersLogo.image = UIImage(named: "error")
            self.emptyTrackersLabel.text = "Что будем отслеживать?"
        } else if visibleCategories.count == 0 {
            self.emptyTrackersLogo.image = UIImage(named: "notFound")
            self.emptyTrackersLabel.text = "Ничего не найдено"
        }
    }
    
    // MARK: - DataBase
    private func fetchData() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
            completedTrackers = try trackerRecordStore.fetchRecords()
        } catch {
            alertPresenter?.showAlert(in: self, error: error)
        }
    }

    // MARK: - public methods
    func setupCollectionView() {
        if visibleCategories.isEmpty {
            trackersCollectionView.isHidden = true
        } else if visibleCategories[0].trackers.count == 0 {
            trackersCollectionView.isHidden = true
        } else {
            trackersCollectionView.isHidden = false
        }
    }
    
    func updateVisibleCategories() {
        fetchData()
        visibleCategories = categories
        dateChanged(datePicker: datePicker)
    }
    
    func reloadTrackerCollectionView() {
        self.trackersCollectionView.reloadData()
    }
    
    func add(_ tracker: Tracker, category: TrackerCategory) {
        do {
            try trackerStore.addTrackerToCategory(tracker, to: category)
        } catch {
            alertPresenter?.showAlert(in: self, error: error)
        }
    }
    

    // MARK: - actions
    @objc func addButtonAction(sender: UIBarButtonItem) {
        let habitVC = HabitViewController()
        habitVC.trackerVCDelegate = self
        
        let createNewTrackerViewController = CreateNewTrackerViewController()
        createNewTrackerViewController.habitVCToPresent = habitVC
        present(createNewTrackerViewController.self, animated: true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let selectedDate = datePicker.date
        let df = DateFormatter()
        df.dateStyle = .short
        df.dateFormat = "dd/MM/yyyy"
        currentDate = selectedDate

        // filter cells
        filterVisibleCategories()
    }
}

// MARK: - работа с searchcontroller
extension TrackerViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        textFilter = (searchController.searchBar.text ?? "").lowercased()
        filterVisibleCategories()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchController.searchBar.endEditing(true)
        textFilter = (searchController.searchBar.text ?? "").lowercased()
        filterVisibleCategories()
        searchBar.resignFirstResponder()
    }
}

// MARK: - работа с ячейкой трекера
extension TrackerViewController: TrackerCellDelegate {
    func completedTracker(id: UUID, at indexPath: IndexPath) {
        if datePicker.date > Date() { return }
        do {
            try trackerRecordStore.addNewRecord(with: id, by: datePicker.date)
        } catch {
            alertPresenter?.showAlert(in: self, error: error)
        }
        fetchData()
        trackersCollectionView.reloadItems(at: [indexPath])
    }
    
    func uncompletedTracker(id: UUID, at indexPath: IndexPath) {
        var recordsToRemove: [TrackerRecord] = []
        
        completedTrackers.removeAll { trackerRecord in
            let isSameDay = Calendar.current.isDate(datePicker.date, inSameDayAs: trackerRecord.date)
            
            if (trackerRecord.id == id && isSameDay) {
                recordsToRemove.append(trackerRecord)
            }
            return trackerRecord.id == id && isSameDay
        }
        for record in recordsToRemove {
            do {
                let tracker = try trackerRecordStore.fetchTrackerRecordCoreData(for: record.id, by: record.date)
                guard let tracker1 = tracker else { return }
                try trackerRecordStore.deleteRecord(tracker1)
            } catch {
                alertPresenter?.showAlert(in: self, error: error)
            }
        }
        fetchData()
        trackersCollectionView.reloadItems(at: [indexPath])
    }
}

extension TrackerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trackers = visibleCategories[section].trackers
        return visibleCategories.isEmpty ? 0 : trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath) as? TrackerCollectionViewCell else {
                return UICollectionViewCell()
        }

        cell.cellDelegate = self
        
        let trackers = visibleCategories[indexPath.section].trackers
        
        if !trackers.isEmpty {
            let tracker = trackers[indexPath.row]
            
            collectionView.backgroundColor = .white
            
            let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
            let completedDays = completedTrackers.filter { $0.id == tracker.id }.count

            cell.updateCell(
                with: tracker,
                isCompletedToday: isCompletedToday,
                completedDays: completedDays,
                indexPath: indexPath
            )
            tracker.emoji.isEmpty ? (cell.emojiContainerView.isHidden = true) : (cell.emojiContainerView.isHidden = false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath
        ) as? SupplementaryView else { return UICollectionReusableView() }
        let titleCategory = visibleCategories[indexPath.section].category
        view.titleLabel.text = titleCategory
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSpacing: CGFloat = 10
        let width: CGFloat = (collectionView.bounds.width - cellSpacing) / 2
        let height: CGFloat = 148
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                            withHorizontalFittingPriority: .required,
                                                            verticalFittingPriority: .fittingSizeLevel)
    }
}

// MARK: - TrackerStoreDelegate
extension TrackerViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        trackersCollectionView.performBatchUpdates {
            trackersCollectionView.insertSections(update.insertedSections)
            trackersCollectionView.insertItems(at: update.insertedIndexPaths)
        }
    }
}
