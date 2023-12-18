//
//  CreateNewTrackerViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 03.12.2023.
//

import UIKit

class CreateNewTrackerViewController: UIViewController {

    var habitVCToPresent: HabitViewController?
    
    // MARK: - private properties
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Создание трекера"
        lbl.textAlignment = .center
        lbl.textColor = .ypBlack
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var habitBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .ypBlack
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Привычка", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(createNewHabitAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var irregularBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .ypBlack
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Нерегулярные события", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        applyConstraints()
    }
    
    // MARK: - private methods
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        containerView.addSubview(habitBtn)
        containerView.addSubview(irregularBtn)
        view.addSubview(containerView)
    }
    
    private func applyConstraints() {
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        let containerViewConstraints = [
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -281),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        let habitBtnConstraints = [
            habitBtn.bottomAnchor.constraint(equalTo: irregularBtn.topAnchor, constant: -16),
            habitBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            habitBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            habitBtn.heightAnchor.constraint(equalToConstant: 60)
        ]
        let irregularBtnConstraints = [
            irregularBtn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            irregularBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            irregularBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            irregularBtn.heightAnchor.constraint(equalTo: habitBtn.heightAnchor)
        ]
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(containerViewConstraints)
        NSLayoutConstraint.activate(habitBtnConstraints)
        NSLayoutConstraint.activate(irregularBtnConstraints)
    }
    
    @objc func createNewHabitAction() {
        guard let habitVCToPresent = habitVCToPresent else { return }
        present(habitVCToPresent.self, animated: true)
    }
}
