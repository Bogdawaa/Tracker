//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 05.12.2023.
//

import UIKit

protocol ScheduleDelegate: AnyObject {
    func updateSchedule(schedule: [Int])
    func updateTable()
}

class ScheduleViewController: UIViewController {
    
    weak var scheduleDelegate: ScheduleDelegate?
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "schedule_title".localized
        lbl.textAlignment = .center
        lbl.textColor = .ypBlack
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var scheduleTableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "identifier")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.layer.cornerRadius = 16
        tv.backgroundColor = .ypGray
        tv.isScrollEnabled = false
        return tv
    }()
    
    private lazy var applyScheduleBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .ypBlack
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(applyScheduleBtnAction), for: .touchUpInside)
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.setTitle("applyScheduleBtn".localized, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let days = [
        "monday_uiswitch".localized,
        "tuesday_uiswitch".localized,
        "wednesday_uiswitch".localized,
        "thursday_uiswitch".localized,
        "friday_uiswitch".localized,
        "saturday_uiswitch".localized,
        "sunday_uiswitch".localized
    ]
    
    private var schedule: [Int] = []
    
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup
        setupView()
        applyConstraints()
        
        // delegates + datasource
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
    }
    
    // MARK: - public methods
    func setupSchedule(with schedule: [Int]) {
        self.schedule = schedule
    }
    
    // MARK: - private methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(scheduleTableView)
        view.addSubview(applyScheduleBtn)
    }
    
    private func applyConstraints() {
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ]
        let scheduleTableViewConstraints = [
            scheduleTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525)
        ]
        let applyScheduleBtnConstraints = [
            applyScheduleBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            applyScheduleBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            applyScheduleBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            applyScheduleBtn.heightAnchor.constraint(equalToConstant: 60)
        ]
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(scheduleTableViewConstraints)
        NSLayoutConstraint.activate(applyScheduleBtnConstraints)
    }
    
    @objc func switchChanged(_ sender: UISwitch!) {
        if sender.isOn {
            schedule.append(sender.tag)
        } else {
            schedule = schedule.filter { $0 != sender.tag}
        }
    }
    
    @objc func applyScheduleBtnAction() {
        if schedule.count > 0 {
            scheduleDelegate?.updateSchedule(schedule: schedule)
            scheduleDelegate?.updateTable()
            dismiss(animated: true)
            return
        }
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let sw = UISwitch(frame: .zero)
        sw.onTintColor = .ypBlue
        sw.setOn(false, animated: true)
        sw.tag = indexPath.row
        sw.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = sw
        cell.backgroundColor = .clear
        cell.textLabel?.text = days[indexPath.row]
        
        if indexPath.row == days.count-1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width * 2)
        } else {
            cell.separatorInset = .zero
        }
        
        // отображение велюченых свичей
        if schedule.count > 0 {
            for day in schedule {
                if day == sw.tag { (sw.isOn = true) }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
