//
//  DeleteConfirmationAlert.swift
//  TrackerApp
//
//  Created by Данил on 23/11/2026.
//

import UIKit

enum DeleteConfirmationAlert {
  static func present(
    on viewController: UIViewController,
    title: String,
    deleteTitle: String = NSLocalizedString("deleteButtonTitle", comment: ""),
    cancelTitle: String = NSLocalizedString("cancelButtonTitle", comment: ""),
    onConfirm: @escaping () -> Void
  ) {
    let alert = UIAlertController(
      title: title,
      message: nil,
      preferredStyle: .actionSheet
    )
    
    alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
    alert.addAction(UIAlertAction(title: deleteTitle, style: .destructive) { _ in
      onConfirm()
    })

    viewController.present(alert, animated: true)
  }
}
