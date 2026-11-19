//
//  TrackersListViewController.swift
//  TrackerApp
//
//  Created by Данил on 04/11/2026.
//

import UIKit

final class TrackersListViewController: UIViewController {
  // MARK: - UI Elements
  private let dateFilterPicker: UIDatePicker = .init()
  private let titleLabel: UILabel = .init()
  private let searchBar: UISearchBar = .init()
  private let emptyStateView: EmptyStateView = .init()
  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    return collectionView
  }()
  
  // MARK: - Private Properties
  private let viewModel: TrackersListViewModel
  
  init(viewModel: TrackersListViewModel = .init()) {
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
  
  // MARK: - Private Methods
  private func bindViewModel() {
    viewModel.onEmptyStateChange = { [weak self] isEmpty in
      if isEmpty {
        self?.showEmptyState()
      } else {
        self?.hideEmptyState()
      }
    }
    viewModel.onUpdate = { [weak self] update in
      self?.apply(update)
    }
  }
  
  private func apply(_ update: TrackersUpdate) {
    switch update {
      case .reload:
        collectionView.reloadData()
      case let .insert(sections, items):
        collectionView.performBatchUpdates {
          collectionView.insertSections(IndexSet(sections))
          collectionView.insertItems(at: items.map(indexPath))
        }
      case let .reloadItems(items):
        collectionView.reloadItems(at: items.map(indexPath))
    }
  }

  private func indexPath(for position: ItemPosition) -> IndexPath {
    IndexPath(item: position.item, section: position.section)
  }

  private func configureNavigationBar() {
    configureAddTrackerButton()
    configureDateFilterPicker()
    configureTitle()
    configureSearchBar()
    
    if #available(iOS 26.0, *) {
      navigationItem.leftBarButtonItem?.hidesSharedBackground = true
      navigationItem.rightBarButtonItem?.hidesSharedBackground = true
    }
  }
  
  private func configureAddTrackerButton() {
    let icon = UIImage(resource: .navPlus).withRenderingMode(.alwaysTemplate)
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: icon,
      style: .plain,
      target: self,
      action: #selector(addTrackerTapped)
    )
    navigationItem.leftBarButtonItem?.tintColor = .blackYP
  }
  
  private func configureDateFilterPicker() {
    dateFilterPicker.datePickerMode = .date
    dateFilterPicker.preferredDatePickerStyle = .compact
    dateFilterPicker.date = viewModel.currentDate
    dateFilterPicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateFilterPicker)
  }
  
  private func configureTitle() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "Трекеры"
    titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
    titleLabel.textColor = .blackYP
    view.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
    ])
  }
  
  private func configureSearchBar() {
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchBar.placeholder = "Поиск"
    searchBar.searchBarStyle = .minimal
    searchBar.delegate = self
    
    view.addSubview(searchBar)
    
    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
      searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
      searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
    ])
  }
  
  private func configureUI() {
    view.backgroundColor = .whiteYP
    configureNavigationBar()
    configureCollection()
    configureEmptyView()
  }
  
  private func configureEmptyView() {
    emptyStateView.translatesAutoresizingMaskIntoConstraints = false
    emptyStateView.config(with: "Что будем отслеживать?")
    view.addSubview(emptyStateView)
    NSLayoutConstraint.activate([
      emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
  
  private func showEmptyState() {
    emptyStateView.isHidden = false
  }
  
  private func hideEmptyState() {
    emptyStateView.isHidden = true
  }
  
  private func configureCollection() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.register(
      TrackerViewCell.self,
      forCellWithReuseIdentifier: TrackerViewCell.reuseIdentifier
    )
    
    collectionView.register(
      HeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: HeaderView.reuseIdentifier
    )
    
    collectionView.backgroundColor = .whiteYP
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.contentInsetAdjustmentBehavior = .never
    
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 18),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant:  16),
      collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
    ])
  }
  
  // MARK: - Actions
  @objc private func addTrackerTapped() {
    let viewController = TrackerTypeSelectionViewController()
    viewController.delegate = viewModel
    let navController = UINavigationController(rootViewController: viewController)
    navController.modalPresentationStyle = .pageSheet
    present(navController, animated: true)
  }
  
  @objc private func dateChanged() {
    viewModel.currentDateDidChange(date: dateFilterPicker.date)
  }
}

// MARK: - UICollectionViewDataSource
extension TrackersListViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    viewModel.numberOfSections
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.numberOfItems(in: section)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader,
          let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderView.reuseIdentifier,
            for: indexPath
          ) as? HeaderView
            else { return UICollectionReusableView() }
    
    header.configureHeader(title: viewModel.headerTitle(for: indexPath.section))
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: TrackerViewCell.reuseIdentifier,
      for: indexPath
    ) as? TrackerViewCell else { return UICollectionViewCell() }
    
    let model = viewModel.cellModel(position: ItemPosition(section: indexPath.section, item: indexPath.row))
    cell.delegate = self
    cell.configureCell(with: model)
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let sideInset: CGFloat = 16
    let available = collectionView.bounds.width - sideInset * 2
    return CGSize(width: floor(available / 2), height: 148)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    getHeaderSize(for: collectionView)
  }
  
  private func getHeaderSize(for collectionView: UICollectionView) -> CGSize {
    let view = HeaderView(frame: .zero)
    view.configureHeader(title: "Header")
    return view.systemLayoutSizeFitting(
      CGSize(width: collectionView.bounds.width, height: UIView.layoutFittingExpandedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel)
  }
}

extension TrackersListViewController: UICollectionViewDelegate {
  
}

// MARK: - TrackerCellDelegate
extension TrackersListViewController: TrackerCellDelegate {
  func trackerCellDidTapDone(_ cell: TrackerViewCell) {
    guard let indexPath = collectionView.indexPath(for: cell) else { return }
    viewModel.didTapDone(at: ItemPosition(section: indexPath.section, item: indexPath.row))
  }
}

// MARK: - UISearchBarDelegate
extension TrackersListViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.searchTextDidChange(searchText: searchText)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}
