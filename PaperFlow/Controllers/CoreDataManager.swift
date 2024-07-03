//
//  CoreDataManager.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-07-02.
//

import Foundation
import CoreData
import AppKit

@objcMembers
class CoreDataManager: NSObject {
  
  // ----------------------------------
  //  MARK: - Constants -
  //
  
  static let shared = CoreDataManager()
  private(set) var mainContext: NSManagedObjectContext
  private(set) var backgroundContext: NSManagedObjectContext
  private let container: NSPersistentContainer
  
  private override init() {
    container = NSPersistentContainer(name: "PaperFlow")
    
    container.loadPersistentStores { _, error in
      if let error = error {
        let nsError = error as NSError
        print("Not able to load core data container. \(nsError.localizedDescription), \(nsError.userInfo)")
        abort()
      }
    }
    
    self.mainContext = self.container.viewContext
    self.mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    self.backgroundContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
    self.backgroundContext.parent = self.mainContext
    self.backgroundContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    
    super.init()
    
    setupNotifications()
  }
  
  
  private func setupNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(saveAllContexts), name: NSApplication.willTerminateNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(saveAllContexts), name: NSApplication.willResignActiveNotification, object: nil)
  }
  
  
  /// Will save the context given and push the save into the main context.
  /// If you want to save only in the child context please provide false
  /// to 'pushToMain'
  func save(context: NSManagedObjectContext, pushToMain: Bool = true, completion: (()->Void)? = nil) {
    context.perform {
      guard context.hasChanges else {
        completion?()
        return
      }
      
      do {
        try context.save()
        print("Core data saved")
        if context != self.mainContext && pushToMain {
          self.mainContext.perform {
            do {
              try self.mainContext.save()
            } catch {
              print("Core data corruption \(error)")
            }
            completion?()
          }
        } else {
          completion?()
        }
      } catch {
        completion?()
      }
    }
  }
  
  /// Save background context to main. Main will be saved last.
  /// This does not update home and device state to core data models.
  @objc private func saveAllContexts() {
    save(context: backgroundContext, pushToMain: true) {
      self.save(context: self.mainContext, pushToMain: true)
    }
  }
}

