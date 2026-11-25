//
//  TrackerStoreSpy.swift
//  TrackerApp
//
//  Created by Данил on 24/11/2026.
//

@testable import TrackerApp
import Foundation

final class TrackerStoreSpy: NSObject, TrackerStoreProtocol {
  weak var delegate: TrackerStoreDelegate?
  private let categoryStore: TrackerCategoryStoreSpy = .init()
  
  func addNewTracker(with tracker: Tracker, to categoryTitle: String) throws {
    
  }
  
  func pinTracker(_ tracker: Tracker) throws {
    
  }
  
  func updateTracker(_ tracker: Tracker, in categoryTitle: String) throws {
    
  }
  
  func deleteTracker(id: UUID) throws {
    
  }
}
