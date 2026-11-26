//
//  CategoryEditorViewController.swift
//  TrackerApp
//
//  Created by Данил on 11/11/2026.
//

import UIKit

final class CategoryEditorViewController: UIViewController {
  var isDone: ((String?, String) -> Void)?
  private let titleField: UITextField = .init()
  private let createButton: UIButton = .init()
  private let oldCategoryTitle: String?
  private let titleView: String
  
  init(titleView: String, oldCategoryTitle: String? = nil) {
    self.oldCategoryTitle = oldCategoryTitle
    self.titleView = titleView
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    AnalyticsService.shared.sendReport(event: .open, screen: .categoryEditor)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    AnalyticsService.shared.sendReport(event: .close, screen: .categoryEditor)
  }
  
  private func configureUI() {
    view.backgroundColor = .whiteYP
    title = titleView
    configureTitleField()
    configureCreateButton()
  }
  
  private func configureTitleField() {
    titleField.translatesAutoresizingMaskIntoConstraints = false
    titleField.backgroundColor = .backgroundYP
    titleField.layer.cornerRadius = 16
    titleField.layer.masksToBounds = true
    titleField.font = .systemFont(ofSize: 17, weight: .regular)
    titleField.textColor = .blackYP
    let placeholderCategoryName = NSLocalizedString("placeholderCategoryName", comment: "")
    titleField.attributedPlaceholder = NSAttributedString(
      string: placeholderCategoryName,
      attributes: [.foregroundColor: UIColor.grayYP]
    )
    titleField.clearButtonMode = .whileEditing
    titleField.returnKeyType = .done
    
    titleField.text = oldCategoryTitle
    
    titleField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
    titleField.leftViewMode = .always
    
    titleField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
    
    view.addSubview(titleField)
    
    NSLayoutConstraint.activate([
      titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      titleField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      titleField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      titleField.heightAnchor.constraint(equalToConstant: 75)
    ])
  }
  
  private func configureCreateButton() {
    createButton.translatesAutoresizingMaskIntoConstraints = false
    let categoryEditorDoneButton = NSLocalizedString("categoryEditorDoneButton", comment: "")
    createButton.setTitle(categoryEditorDoneButton, for: .normal)
    createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    createButton.setTitleColor(.whiteYP, for: .normal)
    createButton.layer.cornerRadius = 16
    createButton.layer.masksToBounds = true
    createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    updateStateCreateButton()
    
    view.addSubview(createButton)
    
    NSLayoutConstraint.activate([
      createButton.heightAnchor.constraint(equalToConstant: 60),
      createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
    ])
  }
  
  private func updateStateCreateButton(_ isEnabled: Bool = false) {
    createButton.isEnabled = isEnabled
    createButton.backgroundColor = isEnabled ? .blackYP: .grayYP
  }
  
  @objc private func titleChanged() {
    let text = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    
    if !text.isEmpty {
      updateStateCreateButton(true)
    } else {
      updateStateCreateButton(false)
    }
  }
  
  @objc private func createButtonTapped() {
    guard let text = titleField.text else { return }
    
    isDone?(oldCategoryTitle, text)
    dismiss(animated: true)
  }
}
