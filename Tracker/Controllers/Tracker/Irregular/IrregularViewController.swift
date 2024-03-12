//
//  IrregularViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 06.03.2024.
//

import UIKit

class IrregularViewController: UIViewController {

    weak var trackerVCDelegate: TrackerVCDelegate?

    // MARK: - private properties
    private var alertPresenter: AlertPresenter?
    private let trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()
    private let categoriesViewModel = CategoriesViewModel()

    
    private var categoryDB: [TrackerCategory] = []
    
    private var trackerNameIsEmpty: Bool = true
    
    private var selectedEmoji = ""
    private var selectedColor = UIColor.ypBlue
    
    private var categoriesVC: CategoriesViewController?
    private var selectedCategory: TrackerCategory? = nil
    private var categoryUpdated: Bool = false

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "irregular_title".localized
        lbl.textAlignment = .center
        lbl.textColor = .ypBlack
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var trackerNameTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.placeholder = "tracker_name_textfield".localized
        tf.layer.cornerRadius = 16
        tf.backgroundColor = .ypGray
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        tf.delegate = self
        return tf
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "identifier")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.layer.cornerRadius = 16
        tv.backgroundColor = .ypGray
        tv.isScrollEnabled = false
        return tv
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = false
        cv.allowsMultipleSelection = false
        cv.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier
        )
        cv.register(
            SupplementaryEmojiView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "headerReusable"
        )
        return cv
    }()
    
    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = false
        cv.allowsMultipleSelection = false
        cv.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorCollectionViewCell.identifier
        )
        cv.register(
            SupplementaryEmojiView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "headerReusable"
        )
        return cv
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        let redColor = UIColor(named: "ypRed")?.cgColor
        btn.layer.borderColor = redColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 16
        btn.backgroundColor = .systemBackground
        btn.setTitle("cancel_button".localized , for: .normal)
        btn.setTitleColor(.ypRed, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(cancelBtnAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var createHabitlBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        btn.layer.cornerRadius = 16
        btn.setTitle("create_tracker_button".localized, for: .normal)
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(createHabitBtnAction), for: .touchUpInside)
        return btn
    }()
    
    private var habitButtons = [
        "category_tableview_cell".localized,
    ]
    private let schedule: [Int] = [0, 1, 2, 3, 4, 5, 6] // для нерегулярного события в расписании выделены все дни
    private let emojiArr = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    private let trackColorArr: [UIColor] = [
        UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1), // red
        UIColor(red: 255/255, green: 136/255, blue: 30/255, alpha: 1), // orange
        UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1), // blue
        UIColor(red: 110/255, green: 68/255, blue: 254/255, alpha: 1), // purple
        UIColor(red: 51/255, green: 207/255, blue: 105/255, alpha: 1), //green
        UIColor(red: 230/255, green: 109/255, blue: 212/255, alpha: 1), // dark pink
        UIColor(red: 249/255, green: 212/255, blue: 212/255, alpha: 1), // light pink
        UIColor(red: 52/255, green: 167/255, blue: 254/255, alpha: 1), // light blue
        UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1), // cyan
        UIColor(red: 53/255, green: 52/255, blue: 124/255, alpha: 1), // dark blue
        UIColor(red: 255/255, green: 103/255, blue: 77/255, alpha: 1), // dark orange
        UIColor(red: 255/255, green: 153/255, blue: 204/255, alpha: 1), // mid pink
        UIColor(red: 246/255, green: 196/255, blue: 139/255, alpha: 1), // light orange
        UIColor(red: 121/255, green: 148/255, blue: 245/255, alpha: 1), // light purple
        UIColor(red: 131/255, green: 44/255, blue: 241/255, alpha: 1), // dark purple
        UIColor(red: 173/255, green: 86/255, blue: 218/255, alpha: 1), // mid purple
        UIColor(red: 141/255, green: 114/255, blue: 230/255, alpha: 1), // very dark purple
        UIColor(red: 47/255, green: 208/255, blue: 88/255, alpha: 1) // dark green
    ]
    

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // setup
        setupView()
        applyConstraints()
        shouldEnableButton()
        
        alertPresenter = AlertPresenter(viewController: self)
        
        // delegates + datasource
        tableView.delegate = self
        tableView.dataSource = self
        
        trackerNameTextField.delegate = self
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        
        categoriesVC = CategoriesViewController(viewModel: categoriesViewModel)
        categoriesViewModel.habitVCDelegate = self
        
        view.addHideKeyboardTapGesture()
        
        do {
            categoryDB = try trackerCategoryStore.fetchCategories()
        } catch {
            alertPresenter?.showAlert(in: self, error: error)
        }
    }
    
    // MARK: - private methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        scrollView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(trackerNameTextField)
        containerView.addSubview(tableView)
        containerView.addSubview(emojiCollectionView)
        containerView.addSubview(colorsCollectionView)
        containerView.addSubview(cancelBtn)
        containerView.addSubview(createHabitlBtn)
        view.addSubview(scrollView)
    }
    
    private func applyConstraints() {
        let scrollViewConstraints = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        let containerViewConstraints = [
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ]
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ]
        let trackerNameTextFieldConstraints = [
            trackerNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            trackerNameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trackerNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75)
        ]
        let tableViewConstraints = [
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 75)
        ]
        let emojiCollectionViewConstraints = [
            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204)
        ]
        let colorsCollectionViewConstraints = [
            colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorsCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            colorsCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 204)
        ]
        let cancelBtnConstraints = [
            cancelBtn.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            cancelBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelBtn.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
            cancelBtn.trailingAnchor.constraint(equalTo: createHabitlBtn.leadingAnchor, constant: -8),
            cancelBtn.heightAnchor.constraint(equalToConstant: 60),
            cancelBtn.widthAnchor.constraint(equalTo: createHabitlBtn.widthAnchor)
        ]
        let createHabitBtnConstraints = [
            createHabitlBtn.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            createHabitlBtn.leadingAnchor.constraint(equalTo: cancelBtn.trailingAnchor),
            createHabitlBtn.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
            createHabitlBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createHabitlBtn.heightAnchor.constraint(equalToConstant: 60)
        ]
        NSLayoutConstraint.activate(scrollViewConstraints)
        NSLayoutConstraint.activate(containerViewConstraints)
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(trackerNameTextFieldConstraints)
        NSLayoutConstraint.activate(tableViewConstraints)
        NSLayoutConstraint.activate(emojiCollectionViewConstraints)
        NSLayoutConstraint.activate(colorsCollectionViewConstraints)
        NSLayoutConstraint.activate(cancelBtnConstraints)
        NSLayoutConstraint.activate(createHabitBtnConstraints)
    }
    
    private func shouldEnableButton() {
        if !trackerNameIsEmpty && selectedCategory != nil {
            createHabitlBtn.backgroundColor = .ypBlack
            createHabitlBtn.setTitleColor(.systemBackground, for: .normal)
            createHabitlBtn.isEnabled = true
        } else {
            createHabitlBtn.backgroundColor = .gray
            createHabitlBtn.setTitleColor(.white, for: .normal)
            createHabitlBtn.isEnabled = false
        }
    }
    
    private func clearData() {
        trackerNameTextField.text = ""
        selectedEmoji = ""
        selectedCategory = nil
        selectedColor = UIColor()
        tableView.reloadData()
    }
    
    
    // MARK: - actions
    @objc func cancelBtnAction() {
        
        self.dismiss(animated: true)
    }
    
    @objc func textChanged(_ textField: UITextField) {
        if trackerNameTextField.text != "" {
            trackerNameIsEmpty = false
            shouldEnableButton()
        } else {
            trackerNameIsEmpty = true
        }
    }
    
    @objc func createHabitBtnAction() {
        guard let trackerName = trackerNameTextField.text,
            let selectedCategory = selectedCategory else { return }
                
        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: schedule.map { WeekDay(id: $0)?.rawValue ?? "" }.joined(separator: ", "),
            isPinned: false,
            isRegular: false
        )
        trackerVCDelegate?.add(tracker, category: selectedCategory)
        trackerVCDelegate?.updateVisibleCategories()
        trackerVCDelegate?.setupCollectionView()
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
}


// MARK: - работа с делегатом экрана категорий
extension IrregularViewController: HabitVCDelegate {
    func getSelectedCategory(category: TrackerCategory?) {
        self.selectedCategory = category
        shouldEnableButton()
        tableView.reloadData()
    }
}

// MARK: - работа с таблицей
extension IrregularViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habitButtons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "habitId")
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = selectedCategory?.category
            cell.separatorInset = .zero
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width * 2)
        }
        cell.textLabel?.text = habitButtons[indexPath.row]
        cell.backgroundColor = .clear
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            guard let categoriesVC = categoriesVC else { return }
            self.present(categoriesVC, animated: true)
        default:
            return
        }
    }
}

// MARK: - работа с textfield
extension IrregularViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 38
        let currentString = (trackerNameTextField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
}

// MARK: - работа с collectionview
extension IrregularViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.emojiCollectionView {
            return emojiArr.count
        }
        if collectionView == self.colorsCollectionView {
            return trackColorArr.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.identifier,
                for: indexPath) as? EmojiCollectionViewCell else {
                    return UICollectionViewCell()
            }
            cell.prepareForReuse()
            cell.configure(emoji: emojiArr[indexPath.row])
            return cell
        }
        else if collectionView == self.colorsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.identifier,
                for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(color: trackColorArr[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    // MARK: - работа с header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "headerReusable"
        default:
            id = ""
        }
        var titleCategory = "Header"
        if collectionView == emojiCollectionView {
            titleCategory = "Emoji"
        } else if collectionView == colorsCollectionView {
            titleCategory = "color_collectionview_title".localized
        }
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath
        ) as! SupplementaryEmojiView
        view.titleLabel.text = titleCategory
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                            withHorizontalFittingPriority: .required,
                                                            verticalFittingPriority: .fittingSizeLevel)
    }
    
    // MARK: - выделение ячеек
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.colorsCollectionView {
            selectedColor = trackColorArr[indexPath.row]
            guard let cell = colorsCollectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else { return }
            cell.layer.borderWidth = 3
            cell.layer.borderColor = selectedColor.cgColor.copy(alpha: 0.3)
            cell.layer.cornerRadius = 8
        } else if collectionView == self.emojiCollectionView {
            selectedEmoji = emojiArr[indexPath.row]
            guard let cell = emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell else { return }
            let color = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 1)
            cell.backgroundColor = color
            cell.layer.cornerRadius = 16
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == self.colorsCollectionView {
            guard let cell = colorsCollectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else { return }
            cell.layer.borderWidth = 0
        } else if collectionView == self.emojiCollectionView {
            guard let cell = emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell else { return }
            cell.backgroundColor = .clear
        }
    }
}


