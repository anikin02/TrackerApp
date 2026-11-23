//
//  StatisticsViewController.swift
//  TrackerApp
//
//  Created by Данил on 04/11/2026.
//

import UIKit

final class StatisticsViewController: UIViewController {
  // MARK: - UI Elements
  private let emptyStateView: EmptyStateView = .init()
  private let tableView: UITableView = .init()
  private let titleLabel: UILabel = .init()
  
  // MARK: - Private Properties
  private let viewModel: StatisticsViewModel = .init()
  
  // MARK: - Lyfecycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.viewWillAppear()
    tableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
  }
  
  // MARK: - Private Methods
  private func bindViewModel() {
    viewModel.onEmptyStateChange = { [weak self] isEmpty in
      guard let self else { return }
      self.showEmptyState(isEmpty)
    }
  }
  
  private func configureUI() {
    view.backgroundColor = .whiteYP
    
    configureTitleLabel()
    configureEmptyStateView()
    configureTableView()
  }
  
  private func configureEmptyStateView() {
    emptyStateView.translatesAutoresizingMaskIntoConstraints = false
    let emptyStatisticsTitle = NSLocalizedString("emptyStatisticsTitle", comment: "")
    emptyStateView.config(with: emptyStatisticsTitle, image: UIImage(resource: .emptyStatisticsState))
    view.addSubview(emptyStateView)
    NSLayoutConstraint.activate([
      emptyStateView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
      emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
  
  private func configureTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(StatisticsViewCell.self, forCellReuseIdentifier: StatisticsViewCell.reuseIdentifier)
    tableView.dataSource = self
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.rowHeight = 102
    tableView.backgroundColor = .none
    tableView.alwaysBounceVertical = false
    
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
  }
  
  private func configureTitleLabel() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = NSLocalizedString("statisticsTitle", comment: "")
    titleLabel.textColor = .blackYP
    titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
    view.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 54),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])
  }
  
  private func showEmptyState(_ isEmpty: Bool) {
    emptyStateView.isHidden = !isEmpty
    tableView.isHidden = isEmpty
  }
}

// MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsViewCell.reuseIdentifier, for: indexPath) as? StatisticsViewCell else {
      return UITableViewCell()
    }
    
    let model = viewModel.makeModel(at: indexPath.row)
    cell.configure(with: model)
    
    return cell
  }
}
