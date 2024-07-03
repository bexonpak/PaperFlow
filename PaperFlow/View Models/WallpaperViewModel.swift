//
//  WallpaperViewModel.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-06-25.
//

import Foundation
import AppKit
import pixivswift

class WallpaperViewModel: ObservableObject {
  
  var globleVIewModel: GlobalSettingsViewModel? = nil
  @Published var images: [Post] = []
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func addNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(getIllustFollow), name: Notification.Name.Release.UpdateWallpaper, object: nil)
  }
  
  @objc func getIllustFollow() {
    guard let globleVIewModel = globleVIewModel else { return }
    images = []
    var _image: [Post] = []
    DispatchQueue.main.async {
      do {
        // load 90 illusts
        for i in 0...3 {
          let results = try globleVIewModel.pixivAPI.illust_follow(restrict: globleVIewModel.getIllustFollowRestrict(), offset: 30 * i)
          print("search: illust_follow \(results.illusts?.count ?? 0)")
          
          let filter = results.illusts?.filter { result in
            if globleVIewModel.getShowR18() {
              return result.ageLimit == .all || result.ageLimit == .r18 || result.ageLimit == .r18g
            } else {
              return result.ageLimit == .all
            }
          }
          for result in filter ?? [] {
            result.illustrationURLs.forEach { urls in
              var request = URLRequest(url: urls.medium)
              request.setValue("https://www.pixiv.net/", forHTTPHeaderField: "Referer")
              let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                  print(error)
                }
                if let data = data,
                   let nsImage = NSImage.init(data: data),
                   nsImage.isValid {
                  _image.append(Post(imageURL: urls.original, image: nsImage, postID: result.id))
                }
              }
              task.resume()
            }
          }
        }
        
        self.images = self.shuffleArray(arr: _image)
        
      } catch {
        print("search failed: \(error)")
      }
    }
  }
  
  func shuffleArray(arr:[Post]) -> [Post] {
    if arr.count >= 1 {
      return arr
    }
    var data:[Post] = arr
    for i in 0..<arr.count {
      let index:Int = Int(arc4random()) % i
      if index != i {
        data.swapAt(i, index)
      }
    }
    return data
  }
}

struct Post: Identifiable,Hashable {
  var id = UUID().uuidString
  var imageURL: URL
  var image: NSImage
  var postID: Int
}
