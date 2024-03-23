//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 05.12.2023.
//

import UIKit

protocol CategoriesViewModelProtocol {
    var viewModel: CategoriesViewModel { get set }
}

final class CategoriesViewController: UIViewController, CategoriesViewModelProtocol {
    
    // MARK: - private properties
    var viewModel: CategoriesViewModel
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "category_title".localized
        lbl.textAlignment = .center
        lbl.textColor = .ypBlack
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
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
    
    private lazy var addNewCategoryBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .ypBlack
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(addNewCategoryBtnAction), for: .touchUpInside)
        btn.setTitle("new_category_button".localized, for: .normal)
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var categoriesTableView: UITableView = {
        let tv = UITableView()
        tv.isHidden = true
        tv.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .clear
        tv.layer.masksToBounds = true
        tv.layer.cornerRadius = 16
        tv.allowsMultipleSelection = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: - init
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        applyConstraints()
        bind()
        
        viewModel.delegate = self
        viewModel.getCategories()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        emptyTrackresView.addSubview(emptyTrackersLogo)
        emptyTrackresView.addSubview(emptyTrackersLabel)
        view.addSubview(emptyTrackresView)
        view.addSubview(categoriesTableView)
        view.addSubview(addNewCategoryBtn)
        applyConstraints()
    }
    
    private func applyConstraints() {
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ]
        let emptyTrackresViewConstraints = [
            emptyTrackresView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyTrackresView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyTrackresView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyTrackresView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        let categoriesTableViewConstraints = [
            categoriesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: addNewCategoryBtn.topAnchor, constant: -75)
        ]
        let addCategoryBtnConstraints = [
            addNewCategoryBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addNewCategoryBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addNewCategoryBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addNewCategoryBtn.heightAnchor.constraint(equalToConstant: 60)
        ]
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(emptyTrackresViewConstraints)
        NSLayoutConstraint.activate(emptyTrackersLogoConstrains)
        NSLayoutConstraint.activate(emptyTrackersLabelConstraints)
        NSLayoutConstraint.activate(categoriesTableViewConstraints)
        NSLayoutConstraint.activate(addCategoryBtnConstraints)
    }
    
    private func bind() {
        viewModel.$categories.bind(action: { [weak self] _ in
            guard let self = self else { return }
            self.categoriesTableView.reloadData()
        })
        viewModel.$isCategoriesEmpty.bind(action: { [weak self] newValue in
            guard let self = self else { return }
            self.setCategoriesTableView(isEmpty: newValue)
        })
    }
    
    private func setCategoriesTableView(isEmpty: Bool) {
        categoriesTableView.isHidden = isEmpty
        emptyTrackresView.isHidden = !isEmpty
    }
    
    private func roundCellCorners(cell: UITableViewCell, radius: Double, mask: CACornerMask) {
        cell.layer.cornerRadius = 16
        cell.layer.maskedCorners = mask
    }
    
    // MARK: - actions
    @objc private func addNewCategoryBtnAction() {
        present(CreateNewCategoryViewController(trackerCategoryStore: viewModel.trackerCategoryStore), animated: true)
    }
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier,
                                                       for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        cell.categoryViewModel = viewModel.categories[indexPath.row]
        
        if indexPath.row == 0 {
            roundCellCorners(cell: cell, radius: 16, mask: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
            cell.separatorInset = .zero
        }
        if indexPath.row == categoriesTableView.numberOfRows(inSection: indexPath.section) - 1 {
            roundCellCorners(cell: cell, radius: 16, mask: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width * 2)
        }
        indexPath == viewModel.selectedCellIndex ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedCellIndex = indexPath
        tableView.reloadData()
        viewModel.setSelectedCategory(categoryIndex: indexPath)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider:  { actionProvider in
            return UIMenu(children: [
                UIAction(title: "Редактировать", handler: { [weak self] _ in
                    guard let self = self else { return }
                    viewModel.editCategory(indexPath)
                }),
                UIAction(title: "Удалить", attributes: .destructive, handler: { [weak self] _ in
                    guard let self = self else { return }
                    
                    let alert = UIAlertController(title: "", message: "Эта категория точно не нужна?", preferredStyle: .actionSheet)

                    alert.addAction(UIAlertAction(title: "Удалить", style: .destructive , handler: { [weak self] _ in
                        guard let self = self else { return }
                        viewModel.deleteCategory(indexPath)
                    }))
                    alert.addAction(UIAlertAction(title: "Отменить", style: .cancel , handler: nil ))
                    self.present(alert, animated: true, completion: nil)
                }),
            ])
        })
    }
}

extension CategoriesViewController: CategoriesViewModeDelegate {
    func showVC(vc: UIViewController) {
        present(vc.self, animated: true)
    }
}
