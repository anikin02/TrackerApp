//
//  TrackerRecordStore.swift
//  TrackerApp
//
//  Created by Данил on 12/11/2026.
//

import CoreData

enum TrackerRecordStoreError: Error {
  case trackerNotFound
}

protocol TrackerRecordStoreDelegate: AnyObject {
  func trackerRecordStoreDidUpdate()
}

final class TrackerRecordStore: NSObject {
  weak var delegate: TrackerRecordStoreDelegate?
  var records: [TrackerRecord] {
    (fetchedResultsController.fetchedObjects ?? []).compactMap(getTrackerRecordModel)
  }
  
  private let context: NSManagedObjectContext
  private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
    let request = TrackerRecordCoreData.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
    
    let controller = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    controller.delegate = self
    do {
      try controller.performFetch()
    } catch {
      assertionFailure("Не удалось загрузить записи: \(error)")
    }
    return controller
  }()
  
  init(context: NSManagedObjectContext) {
    self.context = context
    super.init()
  }
  
  convenience override init() {
    self.init(context: CoreDataStack.shared.viewContext)
  }
  
  func addNewTrackerRecord(trackerRecord: TrackerRecord) throws {
    let request = TrackerCoreData.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", trackerRecord.trackerId as CVarArg)
    request.fetchLimit = 1
    
    guard let tracker = try context.fetch(request).first else {
      throw TrackerRecordStoreError.trackerNotFound
    }
    
    let object = TrackerRecordCoreData(context: context)
    object.date = Calendar.current.startOfDay(for: trackerRecord.date)
    object.tracker = tracker
    
    try context.save()
  }
  
  func removeTrackerRecord(trackerRecord: TrackerRecord) throws {
    let request = recordsRequest(trackerId: trackerRecord.trackerId, on: trackerRecord.date)
    
    let records = try context.fetch(request)
    records.forEach { context.delete($0) }
    
    try context.save()
  }
  
  private func getTrackerRecordModel(object: TrackerRecordCoreData) -> TrackerRecord? {
    guard let date = object.date,
          let tracker = object.tracker,
          let trackerId = tracker.id else { return nil }
    
    return TrackerRecord(trackerId: trackerId, date: date)
  }
  
  private func recordsRequest(trackerId: UUID, on date: Date) -> NSFetchRequest<TrackerRecordCoreData> {
    let day = Calendar.current.startOfDay(for: date)
    
    let request = TrackerRecordCoreData.fetchRequest()
    request.predicate = NSPredicate(
      format: "tracker.id == %@ AND date == %@",
      trackerId as CVarArg,
      day as CVarArg
    )
    return request
  }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    delegate?.trackerRecordStoreDidUpdate()
  }
}

