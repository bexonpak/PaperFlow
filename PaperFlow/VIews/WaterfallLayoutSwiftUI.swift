//
//  WaterfallLayoutSwiftUI.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-07-03.
//

import SwiftUI

struct WaterfallLayoutSwiftUI: NSViewControllerRepresentable {
  
  
  func makeNSViewController(context: Context) -> NSViewController {
    let waterfallLayout = WaterfallLayout()
    waterfallLayout.delegate = self

    let collectionView = NSCollectionView(frame: NSScreen.main!.frame, collectionViewLayout: waterfallLayout)
    collectionView.delegate = self
    collectionView.dataSource = self
    
    
    let viewController = NSViewController()
    viewController.view = collectionView
    return viewController
  }
  
  func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
    
  }
}
