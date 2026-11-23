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
  private let filterButton: UIButton = .init()
  
  // MARK: - Private Properties
  private let viewModel: TrackersListViewModel
  
  // MARK: - Init
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
      guard let self else { return }
      if isEmpty {
        self.showEmptyState()
        self.filterButton.isHidden = !self.viewModel.isFilter
      } else {
        self.hideEmptyState()
        self.filterButton.isHidden = false
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
        dateFilterPicker.date = viewModel.currentDate
      case let .batch(
        deletedSections,
        insertedSections,
        deletedItems,
        insertedItems
      ):
        collectionView.performBatchUpdates {
          collectionView.deleteSections(
            IndexSet(deletedSections)
          )
          collectionView.deleteItems(
            at: deletedItems.map(indexPath)
          )
          collectionView.insertSections(
            IndexSet(insertedSections)
          )
          collectionView.insertItems(
            at: insertedItems.map(indexPath)
          )
        }
      case let .reloadItems(items):
        for position in items {
          guard let cell = collectionView.cellForItem(at: indexPath(for: position))
                  as? TrackerViewCell else { continue }
          cell.configure(with: viewModel.cellModel(position: position))
        }
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
    configureFilterButton()
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
    if viewModel.isFilter || viewModel.isSearch {
      emptyStateView.config(with: "Ничего не найдено", image: UIImage(resource: .emptySearchState))
    } else {
      emptyStateView.config(with: "Что будем отслеживать?")
    }
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
    collectionView.allowsMultipleSelection = false
    collectionView.clipsToBounds = true
    
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    collectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    
    view.addSubview(collectionView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 18),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant:  16),
      collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
    ])
  }
  
  private func configureFilterButton() {
    filterButton.translatesAutoresizingMaskIntoConstraints = false
    filterButton.setTitle("Фильтры", for: .normal)
    filterButton.setTitleColor(.white, for: .normal)
    filterButton.backgroundColor = .blueYP
    filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    filterButton.layer.cornerRadius = 16
    filterButton.layer.masksToBounds = true
    
    view.addSubview(filterButton)
    
    NSLayoutConstraint.activate([
      filterButton.heightAnchor.constraint(equalToConstant: 50),
      filterButton.widthAnchor.constraint(equalToConstant: 114),
      
      filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
      filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
  
  @objc private func filterButtonTapped() {
    let viewModel = FilterViewModel(delegate: self.viewModel)
    let viewController = FilterViewController(viewModel: viewModel)
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
    cell.configure(with: model)
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
  func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
    guard indexPaths.count > 0 else { return nil }
    
    let indexPath = indexPaths[0]
    let position = ItemPosition(section: indexPath.section, item: indexPath.row)
    let isAlreadyPinned = viewModel.isAlreadyPinned(at: position)
    
    return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
      let pin = UIAction(title: isAlreadyPinned ? "Открепить" : "Закрепить") { _ in
        self?.viewModel.didTapPinnedTracker(on: position)
      }
      let edit = UIAction(title: "Редактировать") { _ in
        guard let self else { return }
        self.showEditorViewController(tracker: self.viewModel.getTracker(at: position),
                                      category: self.viewModel.getCategory(at: position))
      }
      let delete = UIAction(title: "Удалить", attributes: .destructive) { _ in
        guard let self else { return }
        DeleteConfirmationAlert.present(on: self, title: "Уверены что хотите удалить трекер?") { [weak self] in
          self?.viewModel.didTapDeletedTracker(at: position)
        }
      }
      return UIMenu(children: [pin, edit, delete])
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
    makeTargetedPreview(for: indexPath)
  }
  
  func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
    makeTargetedPreview(for: indexPath)
  }
  
  private func makeTargetedPreview(for indexPath: IndexPath) -> UITargetedPreview? {
    guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerViewCell else { return nil }
    
    let view = cell.previewView
    let parameters = UIPreviewParameters()
    parameters.backgroundColor = .clear
    parameters.visiblePath = UIBezierPath(roundedRect: view.bounds, cornerRadius: 16)
    return UITargetedPreview(view: view, parameters: parameters)
  }
  
  private func showEditorViewController(tracker: Tracker, category: String) {
    let editorViewModel = TrackerEditorViewModel(isRegularTracker: tracker.isRegular,
                                                 titleView: "Редактирование привычки",
                                                 oldTracker: tracker,
                                                 oldCategory: category)
    editorViewModel.delegate = viewModel
    let editorViewController = TrackerEditorViewController(viewModel: editorViewModel)
    let navController = UINavigationController(rootViewController: editorViewController)
    navController.modalPresentationStyle = .pageSheet
    present(navController, animated: true)
  }
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
