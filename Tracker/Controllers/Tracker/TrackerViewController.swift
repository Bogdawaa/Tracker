//
//  ViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 24.11.2023.
//

import UIKit

final class TrackerViewController: UIViewController, TrackerVCDelegate {
    
    weak var statisticsVCDelegate: StatisticsVCDelegate?
    
    // MARK: - public properties
    var habitVC: HabitViewController?
    
    // MARK: - private properties
    private var alertPresenter: AlertPresenter?
    private var currentDate: Date?
    private var textFilter: String = ""
    private var selectedFilter = Filters.All
    
    private var categories: [TrackerCategory] = []
    
    @Observable
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var pinnedTrackers: [Tracker] = []
    
    private let trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()
    private let trackerStore: TrackerStoreProtocol = TrackerStore()
    private let trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    private let uicolormarshaling = UIColorMarshalling()
    private let filterListViewModel = FilterListViewModel()
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.placeholder = "searchbar_placeholder".localized
        sc.obscuresBackgroundDuringPresentation  = false
        sc.hidesNavigationBarDuringPresentation = false
        return sc
    }()
    
    private lazy var addButton: UIBarButtonItem = {
        let btn = UIBarButtonItem()
        btn.image = UIImage(named: "addButton")
        btn.style = .plain
        btn.target = nil
        btn.tintColor = .ypBlack
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
        lbl.text = "emptyTrackersLabel".localized
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
    
    private lazy var filterButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("filters_button".localized, for: .normal)
        btn.backgroundColor = .ypBlue
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(filterBtnAction), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self

        trackerStore.setDelegate(self)
        filterListViewModel.delegate = self
        alertPresenter = AlertPresenter(viewController: self)
        
        //setup
        updateVisibleCategories()
        setupTabBar()
        setupNavBar()
        setupView()
        setupCollectionView()
        setupSearchController()
        showPlaceholderImage()
        
        bind()
        
        view.addHideKeyboardTapGesture()
    }
    
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = UIColor.systemBackground
        emptyTrackresView.addSubview(emptyTrackersLogo)
        emptyTrackresView.addSubview(emptyTrackersLabel)
        view.addSubview(emptyTrackresView)
        view.addSubview(trackersCollectionView)
        view.addSubview(filterButton)
        applyConstraints()
        
        (self.visibleCategories.count == 0 && selectedFilter == Filters.All) ? (filterButton.isHidden = true) : (filterButton.isHidden = false)
    }
    
    private func setupTabBar() {
        self.tabBarController?.tabBar.layer.borderWidth = 1
        self.tabBarController?.tabBar.layer.borderColor = UIColor.lightGray.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
    }
    
    private func setupNavBar() {
        navigationItem.title = "main_title" .localized
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
        let filterButtonConstraints = [
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(emptyTrackresViewConstraints)
        NSLayoutConstraint.activate(emptyTrackersLogoConstrains)
        NSLayoutConstraint.activate(emptyTrackersLabelConstraints)
        NSLayoutConstraint.activate(trackersCollectionViewConstraints)
        NSLayoutConstraint.activate(filterButtonConstraints)
    }
    
    private func dayOfTheWeek(currentDate: Date) -> String{
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU")
        let index = calendar.component(.weekday, from: currentDate)
        let day = calendar.shortWeekdaySymbols[index-1]
        return day
    }
    
    private func filterVisibleCategories() {
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                switch selectedFilter {
                case .All:
                    let dayOfTheWeek = dayOfTheWeek(currentDate: currentDate ?? datePicker.date)
                    return ((tracker.schedule.contains(dayOfTheWeek) &&
                             (textFilter.isEmpty || tracker.name.lowercased().contains(textFilter)) && tracker.isRegular) || (!tracker.isRegular && !isIrregularTrackerDatePrecede(id: tracker.id)))
                case .Today:
                    datePicker.setDate(Date(), animated: true)
                    currentDate = Date()
                    let dayOfTheWeek = dayOfTheWeek(currentDate: currentDate ?? datePicker.date)
                    return ((tracker.schedule.contains(dayOfTheWeek) &&
                             (textFilter.isEmpty || tracker.name.lowercased().contains(textFilter)) && tracker.isRegular) || (!tracker.isRegular && !isIrregularTrackerDatePrecede(id: tracker.id)))
                case .Completed:
                    let dayOfTheWeek = dayOfTheWeek(currentDate: currentDate ?? datePicker.date)
                    return (((tracker.schedule.contains(dayOfTheWeek) &&
                              (textFilter.isEmpty || tracker.name.lowercased().contains(textFilter)) && tracker.isRegular) || (!tracker.isRegular && !isIrregularTrackerDatePrecede(id: tracker.id))) && isTrackerCompletedToday(id: tracker.id))
                case .Uncompleted:
                    let dayOfTheWeek = dayOfTheWeek(currentDate: currentDate ?? datePicker.date)
                    return (((tracker.schedule.contains(dayOfTheWeek) &&
                              (textFilter.isEmpty || tracker.name.lowercased().contains(textFilter)) && tracker.isRegular) || (!tracker.isRegular && !isIrregularTrackerDatePrecede(id: tracker.id))) && !isTrackerCompletedToday(id: tracker.id))
                }
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(
                category: category.category,
                trackers: trackers
            )
        }
        insertPinnedCategory()
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
    
    private func isIrregularTrackerDatePrecede(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            let isSelectedDayPrecedesCompleted = Calendar.current.compare(
                datePicker.date,
                to: trackerRecord.date,
                toGranularity: .day) == .orderedDescending
            return isSelectedDayPrecedesCompleted && (trackerRecord.id == id)
        }
    }
    
    private func showPlaceholderImage() {
        if (visibleCategories.count == 0) {
            self.emptyTrackersLogo.image = UIImage(named: "error")
            self.emptyTrackersLabel.text = "emptyTrackersLabel".localized
        } else if visibleCategories.count == 0 {
            self.emptyTrackersLogo.image = UIImage(named: "notFound")
            self.emptyTrackersLabel.text = "emptyTrackersLabel_not_found".localized
        }
    }
    
    private func pinTracker(indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        let newTracker = Tracker(
            id: tracker.id,
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emoji,
            schedule: tracker.schedule,
            isPinned: !tracker.isPinned,
            isRegular: tracker.isRegular
        )
        
        try? trackerStore.update(tracker, with: newTracker)
        
        if newTracker.isPinned {
            pinnedTrackers.append(newTracker)
            insertPinnedCategory()
        } else {
            pinnedTrackers.removeAll(where: { $0.id == newTracker.id })
            if pinnedTrackers.count == 0 { visibleCategories.removeFirst() }
        }
        reloadTrackerCollectionView()
    }
    
    private func insertPinnedCategory() {
        let pinnedCategory = TrackerCategory(category: "Закрепленные", trackers: pinnedTrackers)
        if pinnedCategory.trackers.count > 0 {
            visibleCategories.first?.category == "Закрепленные" ? (visibleCategories[0] = pinnedCategory): (visibleCategories.insert(contentsOf: [pinnedCategory], at: 0))
        }
    }
    
    private func editTracker(indexPath: IndexPath) {
        let trackerToChange = visibleCategories[indexPath.section].trackers[indexPath.row]
        let completedDays = completedTrackers.filter { $0.id == trackerToChange.id }.count
        
        if trackerToChange.isRegular {
            let editHabitVC = EditHabitViewController()
            editHabitVC.trackerVCDelegate = self
            editHabitVC.setTrackerToChange(
                tracker: trackerToChange,
                completedDays: completedDays,
                category: visibleCategories[indexPath.section]
            )
            present(editHabitVC.self, animated: true)
        } else {
            let editIrregularVC = EditIrregularViewController()
            editIrregularVC.trackerVCDelegate = self
            editIrregularVC.setTrackerToChange(
                tracker: trackerToChange,
                category: visibleCategories[indexPath.section]
            )
            present(editIrregularVC.self, animated: true)
        }
    }
    
    private func bind() {
        $visibleCategories.bind(action: { [weak self] _ in
            guard let self = self else { return }
            
            (self.visibleCategories.count == 0 && selectedFilter == Filters.All) ? (filterButton.isHidden = true) : (filterButton.isHidden = false)
        })
    }
    
    // MARK: - DataBase
    private func fetchData() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
            completedTrackers = try trackerRecordStore.fetchRecords()
            pinnedTrackers = trackerStore.fetchAllTrackers().filter { $0.isPinned == true }
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
        
        let irregularVC = IrregularViewController()
        irregularVC.trackerVCDelegate = self
        
        let createNewTrackerViewController = CreateNewTrackerViewController()
        createNewTrackerViewController.habitVCToPresent = habitVC
        createNewTrackerViewController.irregularVCToPresent = irregularVC
        present(createNewTrackerViewController.self, animated: true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let selectedDate = datePicker.date
        let df = DateFormatter()
        df.dateStyle = .short
        df.dateFormat = "dd/MM/yyyy"
        currentDate = selectedDate

        filterVisibleCategories()
        
        if selectedFilter == Filters.Today {
            selectedFilter = Filters.All
            filterListViewModel.setSelectedFilter(filterIndex: IndexPath(row: selectedFilter.rawValue, section: 0))
        }
    }
    
    @objc func filterBtnAction() {
        let filterListVC = FilterListViewController(viewModel: filterListViewModel)
        filterListViewModel.delegate = self
        present(filterListVC.self, animated: true)
    }
}

// MARK: - делегат FilterVC
extension TrackerViewController: FilterListVCDelegate {
    func setFilter(filter: Filters) {
        selectedFilter = filter
        updateVisibleCategories()
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
                try trackerRecordStore.deleteRecord(record)
            } catch {
                alertPresenter?.showAlert(in: self, error: error)
            }
        }
        fetchData()
        trackersCollectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - collectionview delegate and datasource
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
    
    // MARK: - контекстное меню
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }

        let indexPath = indexPaths[0]
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        var pinTitle: String
        tracker.isPinned ? (pinTitle = "Открепить") : (pinTitle = "Закрепить")
        
        return UIContextMenuConfiguration(actionProvider:  { actionProvider in
            return UIMenu(children: [
                UIAction(title: pinTitle, handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.pinTracker(indexPath: indexPath)
                }),
                UIAction(title: "Редактировать", handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.editTracker(indexPath: indexPath)
                }),
                UIAction(title: "Удалить", attributes: .destructive, handler: { [weak self] _ in
                    guard let self = self else { return }
                    
                    let alert = UIAlertController(title: "", message: "Уверены что хотите удалить трекер?", preferredStyle: .actionSheet)

                    alert.addAction(UIAlertAction(title: "Удалить", style: .destructive , handler: { [weak self] _ in
                        guard let self = self else { return }
                        try? self.trackerStore.delete(tracker)
                        try? self.trackerRecordStore.deleteRecord(completedTrackers[indexPath.row])
                        self.updateVisibleCategories()
                    }))
                        
                        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel , handler: nil ))
                    self.present(alert, animated: true, completion: nil)
                }),
            ])
        })
        // TODO: доделать выделение только верхней части трекера
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let params = UIPreviewParameters()
        params.backgroundColor = .clear
        
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath) as? TrackerCollectionViewCell else {
                return nil
        }
        
        let preview = UITargetedPreview(view: cell.contentView, parameters: params)
        return preview
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
