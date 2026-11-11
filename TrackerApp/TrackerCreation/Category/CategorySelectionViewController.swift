//
//  CategorySelectionViewController.swift
//  TrackerApp
//
//  Created by Данил on 11/11/2026.
//

import UIKit

final class CategorySelectionViewController: UIViewController {
  var categorySelected: ((String) -> Void)?
  private var categories: [TrackerCategory] = []
  private let tableView: UITableView = .init()
  private let emptyStateView: EmptyStateView = .init()
  private let createCategoryButton: UIButton = .init()
  private var selectedCategoryIndexPath: IndexPath?
  private var tableHeightConstraint: NSLayoutConstraint?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    
    if categories.isEmpty {
      showEmptyStateView()
    } else {
      hideEmptyStateView()
    }
  }
  
  func configureView(with categories: [TrackerCategory]) {
    self.categories = categories
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
  
  func updateTableHeight() {
    tableHeightConstraint?.constant = CGFloat(categories.count) * tableView.rowHeight
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
  
  private func addNewCategory(title: String) {
    categories.append(TrackerCategory(title: title, trackers: []))
    
    let newIndexPath = IndexPath(row: categories.count - 1, section: 0)
    var rowsToReload: [IndexPath] = []
    if newIndexPath.row > 0 {
      rowsToReload.append(IndexPath(row: newIndexPath.row - 1, section: 0))
    }
    
    tableView.performBatchUpdates {
      tableView.insertRows(at: [newIndexPath], with: .automatic)
      tableView.reloadRows(at: rowsToReload, with: .none)
    }
    
    updateTableHeight()
    UIView.animate(withDuration: 0.25) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc private func createCategoryButtonTapped() {
    let categoryVC = CategoryCreationViewController()
    categoryVC.isDone = { [weak self] title in
      guard let self else { return }
      self.addNewCategory(title: title)
    }
    let nav = UINavigationController(rootViewController: categoryVC)
    present(nav, animated: true)
  }
}

extension CategorySelectionViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    categories.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell")
    ?? UITableViewCell(style: .default, reuseIdentifier: "CategoryCell")
    
    cell.textLabel?.text = categories[indexPath.row].title
    cell.textLabel?.font = .systemFont(ofSize: 17)
    cell.textLabel?.textColor = .blackYP
    cell.backgroundColor = .clear
    cell.selectionStyle = .none
    cell.accessoryType = (indexPath == selectedCategoryIndexPath) ? .checkmark : .none
    cell.tintColor = .blueYP
    
    if indexPath.row == categories.count - 1 {
      cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
    } else {
      cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    return cell
  }
}

extension CategorySelectionViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let oldIndexPath = selectedCategoryIndexPath
    guard oldIndexPath != indexPath else { return }
    selectedCategoryIndexPath = indexPath
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    categorySelected?(categories[indexPath.row].title)
    guard let oldIndexPath else { return }
    tableView.cellForRow(at: oldIndexPath)?.accessoryType = .none
  }
}
