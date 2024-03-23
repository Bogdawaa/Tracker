//
//  BlueViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 21.01.2024.
//

import UIKit

class TemplateViewController: UIViewController {
    
    private var onboardingWasShown = false
    
    private var backgroundImageView: UIImageView = {
        var img = UIImage(named: "onboardingBlue")
        var imgView = UIImageView()
        imgView.image = img
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    private var btn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .ypBlack
        btn.setTitle("onboarding_skip_button".localized, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "onboarding_titleLabel".localized
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.numberOfLines = 0
        lbl.sizeToFit()
        lbl.textColor = .ypBlack
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    // MARK: - init
    convenience init() {
        self.init()
    }
    
    init(backgroundImage: UIImage, titleLabelText: String, buttonText: String?) {
        super.init(nibName: nil, bundle: nil)
        
        self.backgroundImageView.image = backgroundImage
        self.titleLabel.text = titleLabelText
        
        guard let buttonText = buttonText else { return }
        self.btn.setTitle(buttonText, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraint()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(btn)
    }
    
    private func setupConstraint() {
        let backgroundImageViewConstraints = [
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        let titleLabelConstraints = [
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ]
        let btnConstraints = [
            btn.heightAnchor.constraint(equalToConstant: 60),
            btn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(backgroundImageViewConstraints)
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(btnConstraints)
    }
    
    // MARK: - objc
    @objc private func nextPage() {
        let tabBar = TabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        onboardingWasShown = true
        UserDefaults.standard.setOnboardingWasShown(value: onboardingWasShown)
        self.present(tabBar, animated: true)
    }
}
