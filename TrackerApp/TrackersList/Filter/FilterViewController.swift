//
//  FilterViewController.swift
//  TrackerApp
//
//  Created by Данил on 21/11/2026.
//

import UIKit

final class FilterViewController: UIViewController {
  let filtersTableView: UITableView = .init()
  let viewModel: FilterViewModel
  
  init(viewModel: FilterViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel() 
  }
  
  private func bindViewModel() {
    viewModel.reloadRows = { [weak self] rows in
      let indexPaths = rows.map { IndexPath(row: $0, section: 0) }
      self?.filtersTableView.reloadRows(at: indexPaths, with: .automatic)
    }
  }
  
  private func configureUI() {
    configureFiltersTableView()
  }
  
  private func configureFiltersTableView() {
    filtersTableView.translatesAutoresizingMaskIntoConstraints = false
    
    filtersTableView.register(FilterTableViewCell.self, forCellReuseIdentifier: FilterTableViewCell.reuseIdentifier)
    
    filtersTableView.dataSource = self
    filtersTableView.delegate = self
    
    filtersTableView.backgroundColor = .backgroundYP
    filtersTableView.layer.cornerRadius = 16
    filtersTableView.layer.masksToBounds = true
    filtersTableView.rowHeight = 75
    filtersTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    let tableHeight = CGFloat(viewModel.numberOfRows) * 75
    view.addSubview(filtersTableView)
    
    NSLayoutConstraint.activate([
      filtersTableView.heightAnchor.constraint(equalToConstant: tableHeight),
      filtersTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])
  }
}

extension FilterViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.didSelectRow(at: indexPath.row)
  }
}

extension FilterViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: FilterTableViewCell.reuseIdentifier,
      for: indexPath) as? FilterTableViewCell else {
      return UITableViewCell()
    }
    
    cell.configureCell(with: viewModel.makeCellModel(for: indexPath.row))
    applySeparator(to: cell, at: indexPath)
    
    return cell
  }
  
  private func applySeparator(to cell: UITableViewCell, at indexPath: IndexPath) {
    let isLast = viewModel.isLastRow(at: indexPath.row)
    cell.separatorInset = UIEdgeInsets(
      top: 0,
      left: 16,
      bottom: 0,
      right: isLast ? .greatestFiniteMagnitude : 16
    )
  }
}
