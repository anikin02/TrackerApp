//
//  ScheduleSelectionViewController.swift
//  TrackerApp
//
//  Created by Данил on 08/11/2026.
//

import UIKit

final class ScheduleSelectionViewController: UIViewController {
  var onDone: ((Set<WeekDay>) -> Void)?
  
  private var selectedDays: Set<WeekDay>
  private let days = WeekDay.orderedWeek
  private let tableView = UITableView()
  private let doneButton = UIButton(type: .custom)
  private let rowHeight: CGFloat = 75
  
  init(selectedDays: Set<WeekDay> = []) {
    self.selectedDays = selectedDays
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .whiteYP
    title = "Расписание"
    configureTable()
    configureDoneButton()
  }
  
  private func configureTable() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.dataSource = self
    tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
    tableView.backgroundColor = .backgroundYP
    tableView.layer.cornerRadius = 16
    tableView.layer.masksToBounds = true
    tableView.isScrollEnabled = false
    tableView.rowHeight = rowHeight
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      tableView.heightAnchor.constraint(equalToConstant: rowHeight * CGFloat(days.count))
    ])
  }
  
  private func configureDoneButton() {
    doneButton.translatesAutoresizingMaskIntoConstraints = false
    doneButton.setTitle("Готово", for: .normal)
    doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    doneButton.setTitleColor(.whiteYP, for: .normal)
    doneButton.backgroundColor = .blackYP
    doneButton.layer.cornerRadius = 16
    doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    
    view.addSubview(doneButton)
    NSLayoutConstraint.activate([
      doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      doneButton.heightAnchor.constraint(equalToConstant: 60)
    ])
  }
  
  @objc private func doneTapped() {
    onDone?(selectedDays)
    dismiss(animated: true)
  }
}

extension ScheduleSelectionViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    days.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: ScheduleCell.identifier, for: indexPath
    ) as? ScheduleCell else { return UITableViewCell() }
    
    let day = days[indexPath.row]
    cell.configCell(title: day.title, isOn: selectedDays.contains(day))
    cell.onToggle = { [weak self] isOn in
      if isOn { self?.selectedDays.insert(day) } else { self?.selectedDays.remove(day) }
    }
    
    if indexPath.row == days.count - 1 {
      cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
    } else {
      cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    return cell
  }
}
