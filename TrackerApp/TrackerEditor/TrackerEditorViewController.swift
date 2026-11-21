//
//  TrackerEditorViewController.swift
//  TrackerApp
//
//  Created by Данил on 06/11/2026.
//

import UIKit

final class TrackerEditorViewController: UIViewController {
  // MARK: - UI Elements
  private let scrollView: UIScrollView = .init()
  private let contentView:UIView = .init()
  private let titleField: UITextField = .init()
  private let errorLabel: UILabel = .init()
  private let titleStack: UIStackView = .init()
  private let optionsTable: UITableView = .init()
  private let emojiColorColletion: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    return collectionView
  }()
  private var emojiColorColletionHeightConstraint: NSLayoutConstraint?
  private let saveButton: UIButton = .init()
  private let cancelButton: UIButton = .init()
  private let stackButtons: UIStackView = .init()
  private let viewModel: TrackerEditorViewModel
  
  init(viewModel: TrackerEditorViewModel) {
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
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let height = calculateEmojiColorCollectionHeight(for: emojiColorColletion.bounds.width)
    if emojiColorColletionHeightConstraint?.constant != height {
      emojiColorColletionHeightConstraint?.constant = height
    }
  }
  
  private func bindViewModel() {
    viewModel.onCreateButtonStateChange = { [weak self] isEnabled in
      isEnabled ? self?.enableCreateButton() : self?.disableCreateButton()
    }
    viewModel.onTitleErrorChange = { [weak self] isVisible in
      self?.setError(visible: isVisible)
    }
    viewModel.onOptionUpdate = { [weak self] row in
      self?.optionsTable.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
    viewModel.onItemsUpdate = { [weak self] positions in
      let paths = positions.map { IndexPath(item: $0.item, section: $0.section) }
      self?.emojiColorColletion.reloadItems(at: paths)
    }
    viewModel.onRoute = { [weak self] route in
      self?.present(route)
    }
    viewModel.onTrackerSaved = { [weak self] _ in
      self?.view.window?.rootViewController?.dismiss(animated: true)
    }
  }
  
  private func present(_ route: NewTrackerRoute) {
    switch route {
      case .category(let selected):
        let viewContoller = CategorySelectionViewController(
          viewModel: CategorySelectionViewModel(selectedTitle: selected)
        )
        viewContoller.categorySelected = { [weak self] title in
          self?.viewModel.didSelectCategory(title)
        }
        present(UINavigationController(rootViewController: viewContoller), animated: true)
        
      case .schedule(let selected):
        let viewContoller = ScheduleSelectionViewController(
          viewModel: ScheduleSelectionViewModel(selectedDays: selected)
        )
        viewContoller.onDone = { [weak self] days in
          self?.viewModel.didSelectSchedule(days)
        }
        present(UINavigationController(rootViewController: viewContoller), animated: true)
    }
  }
  
  private func configureUI() {
    view.backgroundColor = .whiteYP
    title = viewModel.titleView
    
    configureLayout()
    configureTitleField()
    configureOptionsTable()
    configureEmojiColorColletion()
    configureStackButtons()
  }
  
  private func configureLayout() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    contentView.addSubview(titleStack)
    contentView.addSubview(optionsTable)
    contentView.addSubview(emojiColorColletion)
    contentView.addSubview(stackButtons)
    scrollView.addSubview(contentView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
    ])
  }
  
  private func configureTitleField() {
    titleField.translatesAutoresizingMaskIntoConstraints = false
    titleField.backgroundColor = .backgroundYP
    titleField.layer.cornerRadius = 16
    titleField.layer.masksToBounds = true
    titleField.font = .systemFont(ofSize: 17, weight: .regular)
    titleField.textColor = .blackYP
    titleField.attributedPlaceholder = NSAttributedString(
      string: "Введите название трекера",
      attributes: [.foregroundColor: UIColor.grayYP]
    )
    titleField.clearButtonMode = .whileEditing
    titleField.returnKeyType = .done
    titleField.delegate = self
    
    titleField.text = viewModel.initialTitle
    
    titleField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
    titleField.leftViewMode = .always
    
    titleField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
    
    errorLabel.text = viewModel.errorText
    errorLabel.font = .systemFont(ofSize: 17, weight: .regular)
    errorLabel.textColor = .redYP
    errorLabel.textAlignment = .center
    errorLabel.isHidden = true
    
    titleStack.translatesAutoresizingMaskIntoConstraints = false
    titleStack.axis = .vertical
    titleStack.spacing = 8
    titleStack.addArrangedSubview(titleField)
    titleStack.addArrangedSubview(errorLabel)
    
    NSLayoutConstraint.activate([
      titleStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
      titleStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      titleStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      titleField.heightAnchor.constraint(equalToConstant: 75)
    ])
  }
  
  private func configureOptionsTable() {
    optionsTable.translatesAutoresizingMaskIntoConstraints = false
    optionsTable.dataSource = self
    optionsTable.delegate = self
    
    optionsTable.backgroundColor = .backgroundYP
    optionsTable.layer.cornerRadius = 16
    optionsTable.layer.masksToBounds = true
    optionsTable.isScrollEnabled = false
    optionsTable.rowHeight = 75
    optionsTable.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    NSLayoutConstraint.activate([
      optionsTable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      optionsTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      optionsTable.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 24),
      optionsTable.heightAnchor.constraint(equalToConstant: 75 * CGFloat(viewModel.numberOfOptions))
    ])
  }
  
  private func configureEmojiColorColletion() {
    emojiColorColletion.translatesAutoresizingMaskIntoConstraints = false
    emojiColorColletion.register(
      EmojiCell.self,
      forCellWithReuseIdentifier: EmojiCell.reuseIdentifier
    )
    emojiColorColletion.register(
      ColorCell.self,
      forCellWithReuseIdentifier: ColorCell.reuseIdentifier
    )
    emojiColorColletion.register(
      HeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: HeaderView.reuseIdentifier
    )
    emojiColorColletion.backgroundColor = .whiteYP
    emojiColorColletion.delegate = self
    emojiColorColletion.dataSource = self
    emojiColorColletion.contentInsetAdjustmentBehavior = .never
    emojiColorColletion.isScrollEnabled = false
    
    let heightConstraint = emojiColorColletion.heightAnchor.constraint(equalToConstant: 0)
    emojiColorColletionHeightConstraint = heightConstraint
    
    NSLayoutConstraint.activate([
      emojiColorColletion.topAnchor.constraint(equalTo: optionsTable.bottomAnchor, constant: 16),
      emojiColorColletion.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  16),
      emojiColorColletion.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      heightConstraint
    ])
  }
  
  private func configureSaveButton() {
    saveButton.setTitle(viewModel.titleSaveButton, for: .normal)
    saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    saveButton.setTitleColor(.whiteYP, for: .normal)
    saveButton.layer.cornerRadius = 16
    saveButton.layer.masksToBounds = true
    
    saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    disableCreateButton()
  }
  
  private func configureCancelButton() {
    cancelButton.setTitle("Отменить", for: .normal)
    cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    cancelButton.setTitleColor(.redYP, for: .normal)
    cancelButton.backgroundColor = .clear
    
    cancelButton.layer.cornerRadius = 16
    cancelButton.layer.masksToBounds = true
    cancelButton.layer.borderWidth = 1
    cancelButton.layer.borderColor = UIColor.redYP.cgColor
    
    cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
  }
  
  private func configureStackButtons() {
    configureCancelButton()
    configureSaveButton()
    
    stackButtons.translatesAutoresizingMaskIntoConstraints = false
    stackButtons.axis = .horizontal
    stackButtons.spacing = 8
    stackButtons.distribution = .fillEqually
    
    stackButtons.addArrangedSubview(cancelButton)
    stackButtons.addArrangedSubview(saveButton)
    
    NSLayoutConstraint.activate([
      stackButtons.topAnchor.constraint(equalTo: emojiColorColletion.bottomAnchor, constant: 40),
      stackButtons.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      stackButtons.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      stackButtons.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      stackButtons.heightAnchor.constraint(equalToConstant: 60)
    ])
  }
  
  // MARK: - Actions
  @objc private func saveButtonTapped() {
    viewModel.didTappedSaveButton()
  }
  
  @objc private func cancelButtonTapped() {
    dismiss(animated: true)
  }
  
  @objc private func titleChanged() {
    viewModel.titleDidChange(titleField.text ?? "")
  }
  
  // MARK: - Private methods
  private func setError(visible: Bool) {
    guard errorLabel.isHidden == visible else { return }
    UIView.animate(withDuration: 0.2) {
      self.errorLabel.isHidden = !visible
      self.view.layoutIfNeeded()
    }
  }
  
  private func enableCreateButton() {
    saveButton.backgroundColor = .blackYP
    saveButton.isEnabled = true
  }
  
  private func disableCreateButton() {
    saveButton.backgroundColor = .grayYP
    saveButton.isEnabled = false
  }
  
  private func calculateEmojiColorCollectionHeight(for width: CGFloat) -> CGFloat {
    guard width > 0 else { return 0 }
    
    let cellSide = floor(width / viewModel.columnsCount)
    let headerHeight = getHeaderSize(for: emojiColorColletion).height
    
    return (0..<viewModel.numberOfSections).reduce(0) { total, section in
      let rows = ceil(CGFloat(viewModel.numberOfItems(in: section)) / viewModel.columnsCount)
      return total + headerHeight + rows * cellSide
    }
  }
}

// MARK: - UITextFieldDelegate
extension TrackerEditorViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let current = textField.text ?? ""
    guard let swiftRange = Range(range, in: current) else { return false }
    let updated = current.replacingCharacters(in: swiftRange, with: string)
    return viewModel.canChangeTitle(to: updated)
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    viewModel.titleDidClear()
    return true
  }
}

// MARK: - UITableViewDelegate
extension TrackerEditorViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.didSelectOption(at: indexPath.row)
  }
}

// MARK: - UITableViewDataSource
extension TrackerEditorViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.numberOfOptions
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")
    ?? UITableViewCell(style: .subtitle, reuseIdentifier: "OptionCell")
    cell.textLabel?.font = .systemFont(ofSize: 17)
    cell.textLabel?.textColor = .blackYP
    cell.backgroundColor = .clear
    cell.accessoryType = .disclosureIndicator
    cell.selectionStyle = .none
    cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
    cell.detailTextLabel?.textColor = .grayYP
    
    let model = viewModel.optionCellModel(at: indexPath.row)
    cell.textLabel?.text = model.title
    cell.detailTextLabel?.text = model.detail
    
    if viewModel.isLastOption(at: indexPath.row) {
      cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
    } else {
      cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension TrackerEditorViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    viewModel.didSelectItem(at: ItemPosition(section: indexPath.section, item: indexPath.item))
  }
}

// MARK: - UICollectionViewDataSource
extension TrackerEditorViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    viewModel.numberOfSections
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.numberOfItems(in: section)
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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
    let position = ItemPosition(section: indexPath.section, item: indexPath.item)
    guard let item = viewModel.item(at: position) else { return UICollectionViewCell() }
    
    switch item {
      case let .emoji(emoji, isSelected):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath
        ) as? EmojiCell else { return UICollectionViewCell() }
        cell.configureCell(with: emoji, isSelected: isSelected)
        return cell
        
      case let .color(hex, isSelected):
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath
        ) as? ColorCell else { return UICollectionViewCell() }
        cell.configureCell(with: UIColor(hex: hex) ?? .blackYP, isSelected: isSelected)
        return cell
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerEditorViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let available = collectionView.bounds.width
    return CGSize(width: floor(available / viewModel.columnsCount), height: floor(available / viewModel.columnsCount))
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    getHeaderSize(for: collectionView)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    0
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    0
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


