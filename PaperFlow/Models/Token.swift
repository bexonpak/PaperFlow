//
//  Token.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-07-02.
//

import Foundation
import CoreData

class Token: NSManagedObject {
  
  // -------------------------
  // MARK: - Properties -
  //
  
  @NSManaged var userID: Int
  @NSManaged var accessToken: String
  @NSManaged var refreshToken: String
}
