//
//  CategoryCreationViewController.swift
//  TrackerApp
//
//  Created by Данил on 11/11/2026.
//

import UIKit

final class CategoryCreationViewController: UIViewController {
  var isDone: ((String) -> Void)?
  private let titleField: UITextField = .init()
  private let errorLabel: UILabel = .init()
  private let createButton: UIButton = .init()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
  }
  
  private func configureUI() {
    view.backgroundColor = .whiteYP
    title = "Новая категория"
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
    titleField.attributedPlaceholder = NSAttributedString(
      string: "Введите название категории",
      attributes: [.foregroundColor: UIColor.grayYP]
    )
    titleField.clearButtonMode = .whileEditing
    titleField.returnKeyType = .done
    
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
    createButton.setTitle("Готово", for: .normal)
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
    
    isDone?(text)
    dismiss(animated: true)
  }
}
