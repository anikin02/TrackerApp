//
//  CoreDataStack.swift
//  TrackerApp
//
//  Created by Данил on 12/11/2026.
//

import CoreData

final class CoreDataStack {
  static let shared = CoreDataStack()
  
  private init() {}
  
  private(set) lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "DataModel")
    container.loadPersistentStores { _, error in
      if let error {
        assertionFailure("Не удалось загрузить хранилище: \(error)")
      }
    }
    container.viewContext.automaticallyMergesChangesFromParent = true
    return container
  }()
  
  var viewContext: NSManagedObjectContext {
    persistentContainer.viewContext
  }
  
  func saveContext() {
    guard viewContext.hasChanges else { return }
    do {
      try viewContext.save()
    } catch {
      assertionFailure("Не удалось сохранить контекст: \(error)")
    }
  }
}
