//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 05.12.2023.
//

import UIKit

protocol ScheduleDelegate: AnyObject {
    func updateSchedule(schedule: [WeekDay: Bool])
    func updateTable()
}

class ScheduleViewController: UIViewController {
    
    weak var scheduleDelegate: ScheduleDelegate?
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Расписание"
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
        return tv
    }()
    
    private lazy var applyScheduleBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .ypBlack
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(applyScheduleBtnAction), for: .touchUpInside)
        btn.setTitle("Готово", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let days = [
        WeekDay.Monday,
        WeekDay.Tuesday,
        WeekDay.Wednesday,
        WeekDay.Thursday,
        WeekDay.Friday,
        WeekDay.Saturday,
        WeekDay.Sunday,
    ]
    
    // хранит выбранные дни расписания
    private var schedule: [WeekDay: Bool] = [
        WeekDay.Monday: false,
        WeekDay.Tuesday: false,
        WeekDay.Wednesday: false,
        WeekDay.Thursday: false,
        WeekDay.Friday: false,
        WeekDay.Saturday: false,
        WeekDay.Sunday: false
    ]
    
    
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
    
    // MARK: - private methods
    private func setupView() {
        view.backgroundColor = .white
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
        let key = days[sender.tag]
        if sender.isOn {
            schedule[key] = true
        } else {
            schedule[key] = false
        }
    }
    
    @objc func applyScheduleBtnAction() {
        var counter = 0
        for days in schedule {
            if days.value == true {
                counter += 1
                
                if counter >= 1 {
                    scheduleDelegate?.updateSchedule(schedule: schedule)
                    scheduleDelegate?.updateTable()
                    dismiss(animated: true)
                    return
                }
            }
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
        cell.textLabel?.text = days[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}