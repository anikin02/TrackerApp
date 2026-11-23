//
//  ScheduleSelectionViewController.swift
//  TrackerApp
//
//  Created by Данил on 08/11/2026.
//

import UIKit

final class ScheduleSelectionViewController: UIViewController {
  var onDone: ((Set<WeekDay>) -> Void)?
  
  private let tableView = UITableView()
  private let doneButton = UIButton(type: .custom)
  private let rowHeight: CGFloat = 75
  private let viewModel: ScheduleSelectionViewModel
  
  init(viewModel: ScheduleSelectionViewModel = .init()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .whiteYP
    title = NSLocalizedString("scheduleSelectionTitle", comment: "")
    configureTable()
    configureDoneButton()
    bindViewModel()
  }
  
  private func bindViewModel() {
    viewModel.onScheduleConfirmed = { [weak self] days in
      self?.onDone?(days)
      self?.dismiss(animated: true)
    }
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
      tableView.heightAnchor.constraint(equalToConstant: rowHeight * CGFloat(viewModel.numberOfRows))
    ])
  }
  
  private func configureDoneButton() {
    doneButton.translatesAutoresizingMaskIntoConstraints = false
    let doneButtonTitle = NSLocalizedString("doneButtonTitle", comment: "")
    doneButton.setTitle(doneButtonTitle, for: .normal)
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
    viewModel.didTapDone()
  }
}

extension ScheduleSelectionViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: ScheduleCell.identifier, for: indexPath
    ) as? ScheduleCell else { return UITableViewCell() }
    
    let model = viewModel.cellViewModel(at: indexPath.row)
    cell.configCell(title: model.title, isOn: model.selected)
    cell.onToggle = { [weak self, weak cell] isOn in
      guard let self, let cell,
            let indexPath = self.tableView.indexPath(for: cell) else { return }
      self.viewModel.didToggle(at: indexPath.row, isOn: isOn)
    }
    
    let isLast = viewModel.isLastRow(at: indexPath.row)
    cell.separatorInset = UIEdgeInsets(
      top: 0,
      left: 16,
      bottom: 0,
      right: isLast ? .greatestFiniteMagnitude : 16
    )
    return cell
  }
}
