//
//  UIKitView.swift
//  PaperFlow
//
//  Created by Bexon Pak on 2024-07-02.
//
import SwiftUI
import AppKit
import pixivauth
import WebKit
import pixivswift

class LogginViewController: NSViewController, WKNavigationDelegate {
  
  lazy var webview = WKWebView()
  var loginHelper = LoginHelper()
  var completionHandler: ((String) -> Void)? = nil
  var dismissSheet: DismissAction? = nil
  
  override func loadView() {
    view = NSView(frame: NSRect(x: 50, y: 50, width: 400, height: 600))
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.white.cgColor
    webview.navigationDelegate = self
    webview.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    loginHelper.startLogin(onView: webview) { refreshToken in
      print(refreshToken)
      self.completionHandler?(refreshToken)
      self.dismissSheet?()
      return
    }
    view.addSubview(webview)
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
    decisionHandler(.allow)
  }
}

public class URLObserver: NSObject {
  @objc var webview: WKWebView
  var observation: NSKeyValueObservation?
  public var changeHandler: (URL) -> Void
  
  init(webview: WKWebView, changeHandler: @escaping (URL) -> Void) {
    self.webview = webview
    self.changeHandler = changeHandler
    super.init()
    
    observation = observe(\.webview.url, options: .new) { _, change in
      if let value = change.newValue as? URL {
        self.changeHandler(value)
      }
    }
  }
}

public class LoginHelper: NSObject {
  public var oauthData: (String, String) = BasePixivAPI().oauth_pkce()
  public var observer: URLObserver?
  
  public func startLogin(onView webview: WKWebView, completionHandler: @escaping (String) -> Void) {
    webview.load(createRequest(using: self.oauthData))
    self.observer = URLObserver(webview: webview, changeHandler: { url in
      let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
      if let code = components?.queryItems?.first(where: {$0.name == "code"})?.value {
        let r = (try? JSONSerialization.jsonObject(with: Data((BasePixivAPI().handle_code(code, code_challenge: self.oauthData.1, code_verifier: self.oauthData.0)).utf8)) as? [String:Any])?["response"] as? [String:Any]
        if let refresh_token = r?["refresh_token"] as? String {
          completionHandler(refresh_token)
        }
        return
      }
    })
  }
  
  private func createRequest(using oauthData: (String, String)) -> URLRequest {
    
    let login_params = [
      "code_challenge": oauthData.1,
      "code_challenge_method": "S256",
      "client": "pixiv-android"
    ]
    
    var params_string = ""
    for (key, val) in login_params {
      params_string += "\(key)=\(val)&"
    }
    params_string.removeLast()
    let url = URL(string:"https://app-api.pixiv.net/web/v1/login?"+params_string)!
    return URLRequest(url: url)
  }
}


struct LogginViewSwiftUI: NSViewControllerRepresentable {
  typealias NSViewControllerType = LogginViewController
  var completionHandler: (String) -> Void
  @Environment(\.dismiss) var dismiss
  
  func makeNSViewController(context: Context) -> LogginViewController {
    let viewController = LogginViewController()
    viewController.completionHandler = completionHandler
    viewController.dismissSheet = dismiss
    return viewController
  }
  
  func updateNSViewController(_ nsViewController: LogginViewController, context: Context) {
    
  }
}
