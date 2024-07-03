//
//  AppDelegate.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-06-25.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  
  // ----------------------------------
  //  MARK: - Outlets -
  //
  
  //  var settingsWindow: NSWindow!
  @IBOutlet weak var preferenceMenuItem: NSMenuItem!
  
  
  // ----------------------------------
  //  MARK: - Properties -
  //
  
  var mainWindowController: MainWindowController!
  var wallpaperWindow: NSWindow!
  var contentViewModel = ContentViewModel()
  var globalSettingsViewModel = GlobalSettingsViewModel()
  var wallpaperViewModel = WallpaperViewModel()
  var importOpenPanel: NSOpenPanel!
  var eventHandler: Any?
  static var shared = AppDelegate()
  var statusBarItem: NSStatusItem!
  
  
  // ----------------------------------
  //  MARK: - Init -
  //
  
  override init() {
    super.init()
    NSApp.setActivationPolicy(.accessory)
  }
  
  
  // ----------------------------------
  //  MARK: - Lifecycle -
  //
  
  func applicationWillFinishLaunching(_ notification: Notification) {
    
    // 创建设置视窗
    setSettingsWindow()
    
    // 创建桌面壁纸视窗
    setWallpaperWindow()
    
    // 将外部输入传递到壁纸窗口
    AppDelegate.shared.setEventHandler()
  }
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    // 显示桌面壁纸
    self.wallpaperWindow.orderFront(nil)
    
    // Setup menu extra
    setupMenuExtra()
    
    if globalSettingsViewModel.token == nil {
      onPerferencesAction(nil)
    }
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  
  // ----------------------------------
  //  MARK: - Setups -
  //
  
  private func setupMenuExtra() {
    let statusBar = NSStatusBar.system
    statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
    statusBarItem.button?.image = NSImage(systemSymbolName: "desktopcomputer", accessibilityDescription: "PaperFlow menu")
    let statusBarMenu = NSMenu(title: "PaperFlow")
    statusBarItem.menu = statusBarMenu
    statusBarMenu.addItem(
      withTitle: "Perferences…",
      action: #selector(AppDelegate.onPerferencesAction),
      keyEquivalent: ""
    )
    statusBarMenu.addItem(.separator())
    statusBarMenu.addItem(
      withTitle: "Quit",
      action: #selector(AppDelegate.onQuitAction),
      keyEquivalent: ""
    )
    
  }
  
  private func setSettingsWindow() {
    
  }
  
  private func setWallpaperWindow() {
    let menuBarHeight = NSApplication.shared.mainMenu?.menuBarHeight ?? 0
    self.wallpaperWindow = NSWindow()
    self.wallpaperWindow.styleMask = [.borderless, .fullSizeContentView]
    self.wallpaperWindow.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
    self.wallpaperWindow.collectionBehavior = .stationary
    self.wallpaperWindow.setFrame(NSRect(
      origin: .zero,
      size: CGSize(width: NSScreen.main!.visibleFrame.size.width,
                   height: NSScreen.main!.visibleFrame.size.height + NSScreen.main!.visibleFrame.origin.y + 1 + menuBarHeight)), display: true)
    self.wallpaperWindow.isMovable = false
    self.wallpaperWindow.titlebarAppearsTransparent = true
    self.wallpaperWindow.titleVisibility = .hidden
    self.wallpaperWindow.canHide = false
    self.wallpaperWindow.canBecomeVisibleWithoutLogin = true
    self.wallpaperWindow.isReleasedWhenClosed = false
    self.wallpaperWindow.contentView = NSHostingView(rootView: WallpaperView(viewModel: self.wallpaperViewModel).environmentObject(globalSettingsViewModel))
  }
  
  
  // ----------------------------------
  //  MARK: - Actions -
  //
  
  func setEventHandler() {
  }
  
  @IBAction func onPerferencesAction(_ sender: NSMenuItem?) {
    // 创建主视窗
    self.mainWindowController = MainWindowController()
    self.mainWindowController.window.center()
    self.mainWindowController.window.makeKeyAndOrderFront(nil)
    self.mainWindowController.window.level = .floating
  }
  
  @objc func onQuitAction() {
    NSApplication.shared.terminate(self)
  }
  
}

