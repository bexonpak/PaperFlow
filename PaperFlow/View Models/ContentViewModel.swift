//
//  ContentViewModel.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-06-25.
//

import Foundation
import pixivswift
import AppKit

class ContentViewModel: ObservableObject {
  
  let restrict: [Publicity] = [.public, .private]
  
  @Published var isStaging = false
  @Published var restrictSelection = 0 
  @Published var showR18 = false
  
  func updateRestrictSelection(_ publicity: Publicity) {
    if publicity == .public {
      restrictSelection = 0
    } else if publicity == .private {
      restrictSelection = 1
    } else {
      restrictSelection = 0
    }
  }
  
  func updateShowR18(_ show: Bool) {
    showR18 = show
  }
  
  func save(complation: ()-> Void) {
    UserDefaults.standard.setValue(restrict[restrictSelection].rawValue, forKey: "illustFollowRestrict")
    UserDefaults.standard.setValue(showR18, forKey: "showR18")
    NotificationCenter.default.post(name: Notification.Name.Release.UpdateWallpaper, object: nil, userInfo: nil)
    complation()
  }
}
