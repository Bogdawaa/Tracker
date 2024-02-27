//
//  CreateNewCategoryViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 22.01.2024.
//

import UIKit

class CreateNewCategoryViewController: UIViewController, UITextFieldDelegate {

    let trackerCategoryStore: TrackerCategoryStoreProtocol

    // MARK: - private properties

    private var isCategoryNameEmpty: Bool = true
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "new_category_title".localized
        lbl.textAlignment = .center
        lbl.textColor = .ypBlack
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var categoryNameTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.placeholder = "category_name_textfield".localized
        tf.layer.cornerRadius = 16
        tf.backgroundColor = .ypGray
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        tf.delegate = self
        return tf
    }()
    
    private lazy var addCategoryBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(addCategoryBtnAction), for: .touchUpInside)
        btn.setTitle("add_new_category_button".localized, for: .normal)
        btn.isEnabled = false
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    
    // MARK: - init
    init(trackerCategoryStore: TrackerCategoryStoreProtocol) {
        self.trackerCategoryStore = trackerCategoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        view.addHideKeyboardTapGesture()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(categoryNameTextField)
        view.addSubview(addCategoryBtn)
        applyConstraints()
    }
    
    private func applyConstraints() {
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ]
        let categoryNameTextFieldConstraints = [
            categoryNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75)
        ]
        let addCategoryBtnConstraints = [
            addCategoryBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryBtn.heightAnchor.constraint(equalToConstant: 60)
        ]
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(categoryNameTextFieldConstraints)
        NSLayoutConstraint.activate(addCategoryBtnConstraints)
    }
    
    private func setupButton(enable: Bool) {
        var color: UIColor
        enable == true ? (color = .ypBlack): (color = .gray)
        addCategoryBtn.backgroundColor = color
        addCategoryBtn.isEnabled = enable
    }
    
    // MARK: - actions
    @objc private func addCategoryBtnAction() {
        guard let categoryName = categoryNameTextField.text else { return }
        
        let category = TrackerCategory(category: categoryName, trackers: [])
        try? trackerCategoryStore.addNewCategory(category)
        dismiss(animated: true)
    }
    
    @objc func textChanged(_ textField: UITextField) {
        if categoryNameTextField.text != "" {
            isCategoryNameEmpty = false
            setupButton(enable: !isCategoryNameEmpty)
        } else {
            isCategoryNameEmpty = true
            setupButton(enable: !isCategoryNameEmpty)
        }
    }
}
