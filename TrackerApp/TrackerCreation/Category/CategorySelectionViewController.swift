//
//  CategorySelectionViewController.swift
//  TrackerApp
//
//  Created by Данил on 11/11/2026.
//

import UIKit

final class CategorySelectionViewController: UIViewController {
  var categorySelected: ((String) -> Void)?
  private let tableView: UITableView = .init()
  private let emptyStateView: EmptyStateView = .init()
  private let createCategoryButton: UIButton = .init()
  private var tableHeightConstraint: NSLayoutConstraint?
  private let viewModel: CategorySelectionViewModel = .init()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bindViewModel()
    viewModel.viewDidLoad()
  }
  
  private func bindViewModel() {
    viewModel.onTableUpdate = { [weak self] update in
      self?.apply(update)
    }
    viewModel.onEmptyStateChange = { [weak self] isEmpty in
      isEmpty ? self?.showEmptyStateView() : self?.hideEmptyStateView()
    }
    viewModel.onCategorySelected = { [weak self] title in
      self?.categorySelected?(title)
    }
  }
  
  private func apply(_ update: CategorySelectionViewModel.TableUpdate) {
    switch update {
    case .reload:
        tableView.reloadData()
        updateTableHeight()
    case let .insert(inserted, reloadRows):
      tableView.performBatchUpdates {
        tableView.insertRows(at: inserted.map(indexPath), with: .automatic)
      } completion: { [weak self] _ in
        guard let self, !reloadRows.isEmpty else { return }
        self.tableView.reloadRows(at: reloadRows.map(self.indexPath), with: .none)
      }
      updateTableHeight()
      UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    case let .reloadRows(rows):
      tableView.reloadRows(at: rows.map(indexPath), with: .none)
    }
  }

  private func indexPath(for index: Int) -> IndexPath {
    IndexPath(row: index, section: 0)
  }
  
  private func configureUI() {
    view.backgroundColor = .whiteYP
    title = "Категория"
    configureCreateCategoryButton()
    configureTableView()
    configureEmptyStateView()
    updateTableHeight()
  }
  
  private func configureTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
    
    tableView.dataSource = self
    tableView.delegate = self
    
    tableView.backgroundColor = .backgroundYP
    tableView.layer.cornerRadius = 16
    tableView.layer.masksToBounds = true
    tableView.rowHeight = 75
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
    heightConstraint.priority = .defaultHigh
    tableHeightConstraint = heightConstraint
    
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      tableView.bottomAnchor.constraint(lessThanOrEqualTo: createCategoryButton.topAnchor, constant: -24),
      heightConstraint,
    ])
  }
  
  private func updateTableHeight() {
    tableHeightConstraint?.constant = CGFloat(viewModel.numberOfRows) * tableView.rowHeight
  }
  
  private func configureEmptyStateView() {
    emptyStateView.translatesAutoresizingMaskIntoConstraints = false
    emptyStateView.config(with: "Привычки и события можно\nобъединить по смыслу")
    
    view.addSubview(emptyStateView)
    
    NSLayoutConstraint.activate([
      emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      emptyStateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      emptyStateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      emptyStateView.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor)
    ])
  }
  
  private func configureCreateCategoryButton() {
    createCategoryButton.translatesAutoresizingMaskIntoConstraints = false
    createCategoryButton.setTitle("Добавить категорию", for: .normal)
    createCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    createCategoryButton.setTitleColor(.whiteYP, for: .normal)
    createCategoryButton.backgroundColor = .blackYP
    createCategoryButton.layer.cornerRadius = 16
    createCategoryButton.layer.masksToBounds = true
    createCategoryButton.addTarget(self, action: #selector(createCategoryButtonTapped), for: .touchUpInside)
    
    view.addSubview(createCategoryButton)
    
    NSLayoutConstraint.activate([
      createCategoryButton.heightAnchor.constraint(equalToConstant: 60),
      createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
    ])
  }
  
  private func hideEmptyStateView() {
    emptyStateView.isHidden = true
  }
  
  private func showEmptyStateView() {
    emptyStateView.isHidden = false
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
  
  @objc private func createCategoryButtonTapped() {
    let categoryVC = CategoryCreationViewController()
    categoryVC.isDone = { [weak self] title in
      self?.viewModel.addCategory(title: title)
    }
    let nav = UINavigationController(rootViewController: categoryVC)
    present(nav, animated: true)
  }
}

extension CategorySelectionViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: CategoryTableViewCell.reuseIdentifier,
      for: indexPath) as? CategoryTableViewCell else {
      return UITableViewCell()
    }
    
    cell.configureCell(with: viewModel.cellViewModel(at: indexPath.row))
    applySeparator(to: cell, at: indexPath)
    
    return cell
  }
}

extension CategorySelectionViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.didSelectRow(at: indexPath.row)
  }
}
