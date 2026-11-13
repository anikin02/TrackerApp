//
//  TrackersListViewController.swift
//  TrackerApp
//
//  Created by Данил on 04/11/2026.
//

import UIKit

protocol TrackersListDelegate: AnyObject {
  func addNewTracker(tracker: Tracker, category: String)
}

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
  
  // MARK: - Properties
  private var categories: [TrackerCategory] = []
  private var currentDate: Date = Date()
  private var completedTrackers: [TrackerRecord] = []
  private var visibleCategories: [TrackerCategory] = []
  private let trackerCategoryStore: TrackerCategoryStore = .init()
  private let trackerRecordStore: TrackerRecordStore = .init()
  private let trackerStore: TrackerStore = .init()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    
    visibleCategories = getDateCategories()
    
    trackerStore.delegate = self
    trackerRecordStore.delegate = self
    trackerCategoryStore.delegate = self
    reloadFromStores()
  }
  
  // MARK: - Private Methods
  private func reloadFromStores() {
    categories = trackerCategoryStore.categories
    completedTrackers = trackerRecordStore.records
    updateVisibleCategories()
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
    dateFilterPicker.date = currentDate
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
  
  private func getDateCategories() -> [TrackerCategory] {
    var result: [TrackerCategory] = []
    
    for category in categories {
      let title = category.title
      var trackers: [Tracker] = []
      
      for tracker in category.trackers {
        let numberDay = Calendar.current.component(.weekday, from: currentDate)
        if let day = WeekDay(rawValue: numberDay),
           tracker.schedule.contains(day){
          trackers.append(tracker)
        }
      }
      if !trackers.isEmpty {
        result.append(TrackerCategory(title: title, trackers: trackers))
      }
    }
    return result
  }
  
  private func filterBySearch(_ categories: [TrackerCategory], query: String) -> [TrackerCategory] {
    let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else { return categories }
    
    return categories.compactMap { category in
      if category.title.localizedCaseInsensitiveContains(query) {
        return category
      }
      
      let trackers = category.trackers.filter {
        $0.name.localizedCaseInsensitiveContains(query)
      }
      return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
    }
  }
  
  private func updateVisibleCategories() {
    let byDate = getDateCategories()
    visibleCategories = filterBySearch(byDate, query: searchBar.text ?? "")
    collectionView.reloadData()
    
    updateEmptyState()
  }
  
  private func updateEmptyState() {
    if visibleCategories.isEmpty {
      showEmptyState()
    } else {
      hideEmptyState()
    }
  }
  
  // MARK: - Actions
  @objc private func addTrackerTapped() {
    let viewController = TrackerTypeSelectionViewController()
    viewController.delegate = self
    let navController = UINavigationController(rootViewController: viewController)
    navController.modalPresentationStyle = .pageSheet
    present(navController, animated: true)
  }
  
  @objc private func dateChanged() {
    currentDate = dateFilterPicker.date
    updateVisibleCategories()
  }
}

// MARK: - TrackersListDelegate
extension TrackersListViewController: TrackersListDelegate {
  func addNewTracker(tracker: Tracker, category: String) {
    do {
      try trackerStore.addNewTracker(with: tracker, to: category)
    } catch {
      assertionFailure("Не удалось сохранить трекер: \(error)")
    }
  }
}

// MARK: - UICollectionViewDataSource
extension TrackersListViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    visibleCategories.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    visibleCategories[section].trackers.count
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
    
    header.configureHeader(title: visibleCategories[indexPath.section].title)
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: TrackerViewCell.reuseIdentifier,
      for: indexPath
    ) as? TrackerViewCell else { return UICollectionViewCell() }
    
    let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
    
    let model = createCellModel(tracker)
    cell.delegate = self
    cell.configureCell(with: model)
    return cell
  }
  
  private func createCellModel(_ tracker: Tracker) -> TrackerCellModel {
    let daysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
    return TrackerCellModel(
      name: tracker.name,
      emoji: tracker.emoji,
      count: daysCount,
      hexColor: tracker.hexColor,
      isDone: isDone(with: tracker)
    )
  }
  
  private func isDone(with tracker: Tracker) -> Bool {
    completedTrackers.contains {
      $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
    }
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
    guard Calendar.current.startOfDay(for: currentDate) <= Calendar.current.startOfDay(for: Date()) else { return }
    
    let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
    let record = TrackerRecord(trackerId: tracker.id, date: currentDate)
    
    do {
      if isDone(with: tracker) {
        try trackerRecordStore.removeTrackerRecord(trackerRecord: record)
      } else {
        try trackerRecordStore.addNewTrackerRecord(trackerRecord: record)
      }
      completedTrackers = trackerRecordStore.records
      collectionView.reloadItems(at: [indexPath])
    } catch {
      assertionFailure("Не удалось обновить запись: \(error)")
    }
  }
}

// MARK: - UISearchBarDelegate
extension TrackersListViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    updateVisibleCategories()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}

extension TrackersListViewController: TrackerStoreDelegate {
  func trackerStoreDidUpdate() {
    let oldVisible = visibleCategories
    
    categories = trackerCategoryStore.categories
    let newVisible = filterBySearch(getDateCategories(), query: searchBar.text ?? "")
    visibleCategories = newVisible
    
    var insertedSections = IndexSet()
    var insertedItems: [IndexPath] = []
    
    for (newSection, newCategory) in newVisible.enumerated() {
      if let oldCategory = oldVisible.first(where: { $0.title == newCategory.title }) {
        let oldIds = Set(oldCategory.trackers.map(\.id))
        for (item, tracker) in newCategory.trackers.enumerated() where !oldIds.contains(tracker.id) {
          insertedItems.append(IndexPath(item: item, section: newSection))
        }
      } else {
        insertedSections.insert(newSection)
      }
    }
    
    guard !insertedSections.isEmpty || !insertedItems.isEmpty else {
      updateEmptyState()
      return
    }
    
    collectionView.performBatchUpdates {
      collectionView.insertSections(insertedSections)
      collectionView.insertItems(at: insertedItems)
    }
    
    updateEmptyState()
  }
}

extension TrackersListViewController: TrackerRecordStoreDelegate {
  func trackerRecordStoreDidUpdate() {
    // TODO: Пока не уверен, что нужно, так как не хочется перерисовывать всю коллекцию
  }
}

extension TrackersListViewController: TrackerCategoryStoreDelegate {
  func trackerCategoryStoreDidUpdate() {
    // TODO: Скорее всегго понадоиться при удалении категории
  }
}
