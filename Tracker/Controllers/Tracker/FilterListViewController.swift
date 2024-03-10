//
//  FilterListViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 07.03.2024.
//

import UIKit

protocol FilterListViewModelProtocol {
    var viewModel: FilterListViewModel { get set }
}

final class FilterListViewController: UIViewController, FilterListViewModelProtocol {

    var viewModel: FilterListViewModel

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "filters_list_title".localized
        lbl.textAlignment = .center
        lbl.textColor = .ypBlack
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var filtersTableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "identifier")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.layer.cornerRadius = 16
        tv.backgroundColor = .ypGray
        tv.isScrollEnabled = false
        return tv
    }()
    
    // MARK: - init
    init(viewModel: FilterListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(titleLabel)
        view.addSubview(filtersTableView)
        
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
        
        applyConstraints()
        view.backgroundColor = .white
    }
    
    
    // MARK: - private methods
    private func applyConstraints() {
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        let filtersTableViewConstraints = [
            filtersTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: 300)
        ]
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(filtersTableViewConstraints)
    }
}

extension FilterListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel.filtersList[indexPath.row]
        cell.backgroundColor = .ypGray
        
        if indexPath.row == viewModel.filtersList.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width * 2)
        } else {
            cell.separatorInset = .zero
        }
        indexPath == viewModel.selectedCellIndex ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.setSelectedFilter(filterIndex: indexPath)
        dismiss(animated: true)
    }
}
