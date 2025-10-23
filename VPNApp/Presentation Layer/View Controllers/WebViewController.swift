//
//  WebViewController.swift
//  VPNApp
//
//  Created by Munib Hamza on 15/07/2023.
//

import UIKit
import WebKit

class WebViewController: BaseClass, WKNavigationDelegate {
    
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var webVu: WKWebView!

    var urlToLoad : webViewURL = .privacy
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        webVu.navigationDelegate = self
        
        topLbl.text = urlToLoad == .privacy ? "Privacy Policy" : "Terms of Use"
        
        if let url = URL(string: urlToLoad.rawValue) {
            let request = URLRequest(url: url)
            webVu.load(request)
        }
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
