//
//  GlobalSettingsViewModel.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-06-25.
//

import Foundation
import pixivswift
import Erik
import pixivauth
import WebKit

class GlobalSettingsViewModel: NSObject, ObservableObject {
  @Published var isFirstLaunch = UserDefaults.standard.value(forKey: "IsFirstLaunch") as? Bool ?? true
  
  let mainContext = CoreDataManager.shared.mainContext
  @Published var token: Token?
  var pixivAPI = AppPixivAPI()
  
  override init() {
    super.init()
    do {
      let fetchRequest = Token.fetchRequest()
      let object = try mainContext.fetch(fetchRequest)
      if let tokens = object as? [Token],
         let saved = tokens.first {
        setupRefreshToken(saved.refreshToken)
      }
    } catch {
      print("CoreData read failed: \(error)")
    }
  }
  
  func setupRefreshToken(_ refreshToken: String) {
    do {
      let dictionary = try pixivAPI.auth(refresh_token: refreshToken)
      print("Login: \(dictionary)")
      let entity = NSEntityDescription.entity(forEntityName: Token.className, in: mainContext)
      let token = Token(entity: entity!, insertInto: mainContext)
      token.accessToken = pixivAPI.access_token
      token.refreshToken = pixivAPI.refresh_token
      token.userID = pixivAPI.user_id
      CoreDataManager.shared.save(context: CoreDataManager.shared.mainContext)
      pixivAPI.set_auth(access_token: token.accessToken, refresh_token: token.refreshToken)
      self.token = token
    } catch {
      print("Login failed: \(error)")
    }
  }
  
  func logout() {
    let fetchRequest = Token.fetchRequest()
    let results = try? mainContext.fetch(fetchRequest)
    for object in results ?? [] {
      if let object = object as? NSManagedObject {
        mainContext.delete(object)
      }
    }
    CoreDataManager.shared.save(context: CoreDataManager.shared.mainContext)
    token = nil
  }
  
  func getIllustFollowRestrict() -> Publicity {
    let illustFollowRestrict = UserDefaults.standard.string(forKey: "illustFollowRestrict") ?? Publicity.public.rawValue
    if illustFollowRestrict == Publicity.public.rawValue {
      return Publicity.public
    } else if illustFollowRestrict == Publicity.private.rawValue {
      return Publicity.private
    } else {
      return Publicity.public
    }
  }
  
  func getShowR18() -> Bool {
    return UserDefaults.standard.bool(forKey: "showR18")
  }
  
}

extension GlobalSettingsViewModel: WKUIDelegate {
}
