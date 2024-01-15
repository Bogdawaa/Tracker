////
////  ViewController.swift
////  Tracker
////
////  Created by Bogdan Fartdinov on 24.11.2023.
////
//
//import UIKit
//
//final class TrackerViewController: UIViewController, TrackerVCDelegate {
//
//    // MARK: - public properties
//    var habitVC: HabitViewController?
//
//    // MARK: - private properties
//    private let trackerCategoryStore = TrackerCategoryStore.shared
//    private let trackerStore = TrackerStore.shared
//    private let trackerRecordStore = TrackerRecordStore.shared
//    private let trackerService = TrackerService.shared
//    private let uicolormarshaling = UIColorMarshalling()
//
//
//    private lazy var searchController: UISearchController = {
//        let sc = UISearchController(searchResultsController: nil)
//        sc.searchBar.placeholder = "Поиск"
//        sc.obscuresBackgroundDuringPresentation  = false
//        sc.hidesNavigationBarDuringPresentation = false
//        return sc
//    }()
//
//    private lazy var addButton: UIBarButtonItem = {
//        let btn = UIBarButtonItem()
//        btn.image = UIImage(named: "addButton")
//        btn.style = .plain
//        btn.target = nil
//        btn.tintColor = .black
//        btn.target = self
//        btn.action = #selector(addButtonAction(sender:))
//        return btn
//    }()
//
//    private lazy var datePicker: UIDatePicker = {
//        let dp = UIDatePicker()
//        dp.datePickerMode = .date
//        dp.preferredDatePickerStyle = .compact
//        dp.locale = Locale(identifier: "ru_RU")
//        dp.clipsToBounds = true
//        dp.layer.cornerRadius = 8
//        dp.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
//        NSLayoutConstraint.activate([dp.widthAnchor.constraint(equalToConstant: 120)])
//        return dp
//    }()
//
//    private lazy var emptyTrackresView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    private lazy var emptyTrackersLogo: UIImageView = {
//        let iv = UIImageView()
//        let img = UIImage(named: "error")
//        iv.image = img
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        return iv
//    }()
//
//    private lazy var emptyTrackersLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Что будем отслеживать?"
//        lbl.textAlignment = .center
//        lbl.font = .systemFont(ofSize: 12, weight: .medium)
//        lbl.textColor = .ypBlack
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        return lbl
//    }()
//
//    lazy var trackersCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 200, height: 200)
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.register(
//            TrackerCollectionViewCell.self,
//            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
//        )
//        cv.register(
//            SupplementaryView.self,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "header"
//        )
//        cv.backgroundColor = .clear
//        cv.translatesAutoresizingMaskIntoConstraints = false
//        return cv
//    }()
//
//    private var currentDate: Date?
//    private var trackerServiceObserver: NSObjectProtocol?
//    private var textFilter: String = ""
//
//    private var trackersDB: [TrackerCoreData] = []
//    private var categoryDB: [TrackerCategoryCoreData] = []
//    private var recordDB: [TrackerRecordCoreData] = []
//
//    private var categories: [TrackerCategory] = [TrackerCategory]()
//    private var visibleCategories: [TrackerCategory] = [TrackerCategory]()
//
//
//    // MARK: - Lyfecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        trackersCollectionView.dataSource = self
//        trackersCollectionView.delegate = self
//
//        //setup
//        updateVisibleCategories()
//        setupTabBar()
//        setupNavBar()
//        setupView()
//        setupCollectionView()
//        setupSearchController()
//        showPlaceholderImage()
//
//        print("recordsDB on start: \(recordDB)")
//
//    }
//
//    // MARK: - Setup
//    private func setupView() {
//        view.backgroundColor = .white
//        emptyTrackresView.addSubview(emptyTrackersLogo)
//        emptyTrackresView.addSubview(emptyTrackersLabel)
//        view.addSubview(emptyTrackresView)
//        view.addSubview(trackersCollectionView)
//        applyConstraints()
//    }
//
//    private func setupTabBar() {
//        self.tabBarController?.tabBar.layer.borderWidth = 1
//        self.tabBarController?.tabBar.layer.borderColor = UIColor.lightGray.cgColor
//        self.tabBarController?.tabBar.clipsToBounds = true
//    }
//
//    private func setupNavBar() {
//        navigationItem.title = "Трекеры"
//        navigationItem.leftBarButtonItem = addButton
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
//        navigationItem.searchController = searchController
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
//
//    }
//
//    private func setupSearchController() {
//        searchController.searchBar.delegate = self
//        searchController.searchResultsUpdater = self
//    }
//
//    private func applyConstraints() {
//        let emptyTrackresViewConstraints = [
//            emptyTrackresView.topAnchor.constraint(equalTo: view.topAnchor),
//            emptyTrackresView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            emptyTrackresView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            emptyTrackresView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
//        ]
//
//        let emptyTrackersLogoConstrains = [
//            emptyTrackersLogo.heightAnchor.constraint(equalToConstant: 80),
//            emptyTrackersLogo.widthAnchor.constraint(equalToConstant: 80),
//            emptyTrackersLogo.centerXAnchor.constraint(equalTo: emptyTrackresView.centerXAnchor),
//            emptyTrackersLogo.centerYAnchor.constraint(equalTo: emptyTrackresView.centerYAnchor)
//        ]
//        let emptyTrackersLabelConstraints = [
//            emptyTrackersLabel.centerXAnchor.constraint(equalTo: emptyTrackresView.centerXAnchor),
//            emptyTrackersLabel.topAnchor.constraint(equalTo: emptyTrackersLogo.bottomAnchor, constant: 8)
//        ]
//        let trackersCollectionViewConstraints = [
//            trackersCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
//            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84)
//        ]
//        NSLayoutConstraint.activate(emptyTrackresViewConstraints)
//        NSLayoutConstraint.activate(emptyTrackersLogoConstrains)
//        NSLayoutConstraint.activate(emptyTrackersLabelConstraints)
//        NSLayoutConstraint.activate(trackersCollectionViewConstraints)
//    }
//
//    private func dayOfTheWeek(currentDate: Date) -> String{
//        let index = Calendar.current.component(.weekday, from: currentDate)
//        let day = Calendar.current.shortWeekdaySymbols[index-1]
//        print("day is: \(day)")
//        return day
//    }
//
//    private func filterVisibleCategories() {
//        let dayOfTheWeek = dayOfTheWeek(currentDate: currentDate ?? datePicker.date)
//        visibleCategories = categories.compactMap { category in
//            let trackers = category.trackers.filter { tracker in
//                tracker.schedule.contains { weekDay in
//                    (weekDay.key.rawValue == dayOfTheWeek) && (weekDay.value == true) &&
//                    (textFilter.isEmpty || tracker.name.lowercased().contains(textFilter))
//                }
//            }
//            if trackers.isEmpty {
//                return nil
//            }
//            return TrackerCategory(
//                category: category.category,
//                trackers: trackers
//            )
//        }
//        showPlaceholderImage()
//        setupCollectionView()
//        trackersCollectionView.reloadData()
//    }
//
//    private func isTrackerCompletedToday(id: UUID) -> Bool {
//        recordDB.contains { trackerRecord in
//            let isSameDay = Calendar.current.isDate(datePicker.date, inSameDayAs: trackerRecord.date ?? Date())
//            return isSameDay && (trackerRecord.id == id)
//        }
//    }
//
//    private func showPlaceholderImage() {
//        if (trackerService.trackers.count == 0 && trackerService.trackers.count == 0) {
//            self.emptyTrackersLogo.image = UIImage(named: "error")
//            self.emptyTrackersLabel.text = "Что будем отслеживать?"
//        } else if visibleCategories.count == 0 {
//            self.emptyTrackersLogo.image = UIImage(named: "notFound")
//            self.emptyTrackersLabel.text = "Ничего не найдено"
//        }
//    }
//
//    // MARK: - DataBase
//    private func fetchData() {
//        trackersDB = trackerStore.fetchTrackers()
//        categoryDB = trackerCategoryStore.fetchCategory()
//        recordDB = trackerRecordStore.fetchRecords()
//    }
//
//    private func categoriesFromFetchedData() -> [TrackerCategory] {
//        var newArr: [TrackerCategory] = []
//        for category in categoryDB {
//            let trackers = trackerStore.fetchTrackersByCategory(trackerCategory: category)
//
//            var convertedTrackers: [Tracker] = []
//            for tracker in trackers {
//                let newItem = Tracker(id: tracker.id ?? UUID(),
//                                      name: tracker.name ?? "",
//                                      color: uicolormarshaling.color(from: tracker.color ?? ""),
//                                      emoji: tracker.emoji ?? "",
//                                      schedule: tracker.schedule as! [WeekDay : Bool]
//                )
//                convertedTrackers.append(newItem)
//            }
//            let newItem = TrackerCategory(category: category.category!, trackers: convertedTrackers)
//            newArr.append(newItem)
//        }
//        return newArr
//    }
//
//
//    // MARK: - public methods
//    func setupCollectionView() {
//        if visibleCategories.isEmpty {
//            trackersCollectionView.isHidden = true
//        } else if visibleCategories[0].trackers.count == 0 {
//            trackersCollectionView.isHidden = true
//        } else {
//            trackersCollectionView.isHidden = false
//        }
//    }
//
//    func updateVisibleCategories() {
//        fetchData()
//        categories = categoriesFromFetchedData()
//        visibleCategories = categories
//        dateChanged(datePicker: datePicker)
//    }
//
//    func reloadTrackerCollectionView() {
//        self.trackersCollectionView.reloadData()
//    }
//
//
//    // MARK: - actions
//    @objc func addButtonAction(sender: UIBarButtonItem) {
//        let habitVC = HabitViewController()
//        habitVC.trackerVCDelegate = self
//
//        let createNewTrackerViewController = CreateNewTrackerViewController()
//        createNewTrackerViewController.habitVCToPresent = habitVC
//        present(createNewTrackerViewController.self, animated: true)
//    }
//
//    @objc func dateChanged(datePicker: UIDatePicker) {
//        let selectedDate = datePicker.date
//        let df = DateFormatter()
//        df.dateStyle = .short
//        df.dateFormat = "dd/MM/yyyy"
//        currentDate = selectedDate
//
//        // filter cells
//        filterVisibleCategories()
//    }
//}
//
//// MARK: - работа с searchcontroller
//extension TrackerViewController: UISearchBarDelegate, UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        textFilter = (searchController.searchBar.text ?? "").lowercased()
//        filterVisibleCategories()
//    }
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        self.searchController.searchBar.endEditing(true)
//        textFilter = (searchController.searchBar.text ?? "").lowercased()
//        filterVisibleCategories()
//        searchBar.resignFirstResponder()
//    }
//}
//
//// MARK: - работа с ячейкой трекера
//extension TrackerViewController: TrackerCellDelegate {
//    func completedTracker(id: UUID, at indexPath: IndexPath) {
//        if datePicker.date > Date() { return }
//        let tr = TrackerRecord(id: id, date: datePicker.date)
//        do {
//            try trackerRecordStore.addNewRecord(tr)
//        } catch {
//            print("Error trying save trackerRecord")
//        }
//        fetchData()
//        trackersCollectionView.reloadItems(at: [indexPath])
//        print("recordsDB: \(recordDB)")
//    }
//
//    func uncompletedTracker(id: UUID, at indexPath: IndexPath) {
//        var recordsToRemove: [TrackerRecordCoreData] = []
//        recordDB.removeAll { trackerRecord in
//            let isSameDay = Calendar.current.isDate(datePicker.date, inSameDayAs: trackerRecord.date!)
//
//            if (trackerRecord.id == id && isSameDay) {
//                recordsToRemove.append(trackerRecord)
//            }
//            return trackerRecord.id == id && isSameDay
//        }
//        for record in recordsToRemove {
//            TrackerRecordStore.shared.deleteRecord(record)
//        }
//        fetchData()
//        trackersCollectionView.reloadItems(at: [indexPath])
//    }
//}
//
//extension TrackerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let trackers = visibleCategories[section].trackers
//        return trackers.count
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return visibleCategories.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: TrackerCollectionViewCell.identifier,
//            for: indexPath) as? TrackerCollectionViewCell else {
//                return UICollectionViewCell()
//        }
//        cell.cellDelegate = self
//
//        let trackers = visibleCategories[indexPath.section].trackers
//
//        if trackers.count > 0 {
//            let tracker = trackers[indexPath.row]
//
//            collectionView.backgroundColor = .white
//
//            let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
//            let completedDays = recordDB.filter { $0.id == tracker.id }.count
//
//            cell.updateCell(
//                with: tracker,
//                isCompletedToday: isCompletedToday,
//                completedDays: completedDays,
//                indexPath: indexPath
//            )
//            tracker.emoji.isEmpty ? (cell.emojiContainerView.isHidden = true) : (cell.emojiContainerView.isHidden = false)
//        }
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        var id: String
//        switch kind {
//        case UICollectionView.elementKindSectionHeader:
//            id = "header"
//        default:
//            id = ""
//        }
//        guard let view = collectionView.dequeueReusableSupplementaryView(
//            ofKind: kind,
//            withReuseIdentifier: id,
//            for: indexPath
//        ) as? SupplementaryView else { return UICollectionReusableView() }
//        let titleCategory = visibleCategories[indexPath.section].category
//        view.titleLabel.text = titleCategory
//
//        return view
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 167, height: 148)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        let indexPath = IndexPath(row: 0, section: section)
//        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
//
//        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
//                                                         height: UIView.layoutFittingExpandedSize.height),
//                                                            withHorizontalFittingPriority: .required,
//                                                            verticalFittingPriority: .fittingSizeLevel)
//    }
//}
