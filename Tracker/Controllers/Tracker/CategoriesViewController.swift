//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 05.12.2023.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    // MARK: - private properties
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Категория"
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
        lbl.text = "Привычки и события можно объединить по смыслу"
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .ypBlack
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var addCategoryBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .ypBlack
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(addCategoryBtnAction), for: .touchUpInside)
        btn.setTitle("Добавить категорию", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var categories: [TrackerCategory] = [TrackerCategory]()
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        applyConstraints()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        emptyTrackresView.addSubview(emptyTrackersLogo)
        emptyTrackresView.addSubview(emptyTrackersLabel)
        view.addSubview(emptyTrackresView)
        view.addSubview(addCategoryBtn)
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
        let addCategoryBtnConstraints = [
            addCategoryBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryBtn.heightAnchor.constraint(equalToConstant: 60)
        ]
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(emptyTrackresViewConstraints)
        NSLayoutConstraint.activate(emptyTrackersLogoConstrains)
        NSLayoutConstraint.activate(emptyTrackersLabelConstraints)
        NSLayoutConstraint.activate(addCategoryBtnConstraints)
    }
    
    // MARK: - actions
    @objc func addCategoryBtnAction() {
        dismiss(animated: true)
        // TODO: реализовать создание категорий
    }
}
