//
//  NSObject.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-07-02.
//

import Foundation

extension NSObject {
  @objc var className: String {
    return String(describing: type(of: self))
  }
  
  class var className: String {
    return String(describing: self)
  }
}
