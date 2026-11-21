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
  private let editorCategoryButton: UIButton = .init()
  private var tableHeightConstraint: NSLayoutConstraint?
  private let viewModel: CategorySelectionViewModel
  
  init(viewModel: CategorySelectionViewModel = .init()) {
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
      case let .batch(deleted, inserted):
        tableView.performBatchUpdates ({
          tableView.deleteRows(at: deleted.map(indexPath), with: .automatic)
          tableView.insertRows(at: inserted.map(indexPath), with: .automatic)
        }, completion: { [weak self] _ in
          self?.refreshSeparators()
        })
        updateTableHeight()
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
      case let .reloadRows(rows):
        for row in rows {
          let path = indexPath(for: row)
          guard let cell = tableView.cellForRow(at: path) as? CategoryTableViewCell else { continue }
          cell.configureCell(with: viewModel.cellViewModel(at: row))
        }
    }
  }
  
  private func indexPath(for index: Int) -> IndexPath {
    IndexPath(row: index, section: 0)
  }
  
  private func refreshSeparators() {
    for case let cell as CategoryTableViewCell in tableView.visibleCells {
      guard let path = tableView.indexPath(for: cell) else { continue }
      applySeparator(to: cell, at: path)
    }
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
      tableView.bottomAnchor.constraint(lessThanOrEqualTo: editorCategoryButton.topAnchor, constant: -24),
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
      emptyStateView.bottomAnchor.constraint(equalTo: editorCategoryButton.topAnchor)
    ])
  }
  
  private func configureCreateCategoryButton() {
    editorCategoryButton.translatesAutoresizingMaskIntoConstraints = false
    editorCategoryButton.setTitle("Добавить категорию", for: .normal)
    editorCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    editorCategoryButton.setTitleColor(.whiteYP, for: .normal)
    editorCategoryButton.backgroundColor = .blackYP
    editorCategoryButton.layer.cornerRadius = 16
    editorCategoryButton.layer.masksToBounds = true
    editorCategoryButton.addTarget(self, action: #selector(editorCategoryButtonTapped), for: .touchUpInside)
    
    view.addSubview(editorCategoryButton)
    
    NSLayoutConstraint.activate([
      editorCategoryButton.heightAnchor.constraint(equalToConstant: 60),
      editorCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      editorCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      editorCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
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
  
  @objc private func editorCategoryButtonTapped() {
    showEditorCategory(titleView: "Новая категория")
  }
  
  private func showEditorCategory(titleView: String, oldCategoryTitle: String? = nil) {
    let categoryVC = CategoryEditorViewController(titleView: titleView, oldCategoryTitle: oldCategoryTitle)
    categoryVC.isDone = { [weak self] oldTitle, title in
      if let oldTitle {
        self?.viewModel.updateCategory(oldTitle: oldTitle, newTitle: title)
      } else {
        self?.viewModel.addCategory(title: title)
      }
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
  
  func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
    return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
      let edit = UIAction(title: "Редактировать") { _ in
        guard let self else { return }
        let category = self.viewModel.cellViewModel(at: indexPath.row)
        self.showEditorCategory(titleView: "Редактирование категории", oldCategoryTitle: category.title)
      }
      let delete = UIAction(title: "Удалить", attributes: .destructive) { _ in
        self?.viewModel.deleteCategory(at: indexPath.row)
      }
      return UIMenu(children: [edit, delete])
    }
  }
}
