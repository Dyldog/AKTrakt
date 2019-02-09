//
//  TraktAuthenticationViewController.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

public class TraktAuthenticationViewController: UIViewController, WKNavigationDelegate {

    private var wkWebview: WKWebView!
	private weak var delegate: TraktAuthViewControllerDelegate!
	private let trakt: Trakt

    public init(trakt: Trakt, delegate: TraktAuthViewControllerDelegate) {
        self.trakt = trakt
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(TraktAuthenticationViewController.cancel))

        wkWebview = WKWebView(frame: view.bounds)
        wkWebview.navigationDelegate = self

        view.addSubview(wkWebview)

        initWebview()
    }

	public static func credientialViewController(trakt: Trakt, delegate: TraktAuthViewControllerDelegate) -> UIViewController? {
		if !trakt.hasValidToken() {
			return UINavigationController(rootViewController: TraktAuthenticationViewController(trakt: trakt, delegate: delegate))
		}
		return nil
	}

    @IBAction public func cancel() {
		delegate?.TraktAuthViewControllerDidCancel(controller: self)
    }

    private func initWebview() {
		wkWebview.load(NSURLRequest(url: NSURL(string: "http://trakt.tv/pin/\(trakt.applicationId)")! as URL) as URLRequest)
    }

    private func pinFromNavigation(action: WKNavigationAction) -> String? {
		if let path = action.request.url?.path, path.contains("/oauth/authorize/") {
			let query = action.request.url?.query
			return query?.components(separatedBy: "=")[1]
			
        }
        return nil
    }

	public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
		if let pin = pinFromNavigation(action: navigationAction) {
			decisionHandler(.cancel)
			_ = TraktRequestToken(trakt: trakt, pin: pin).request(trakt: trakt) { token, error in
                guard token != nil else {
                    UIAlertView(title: "", message: "Failed to get a valid token", delegate: nil, cancelButtonTitle: "OK").show()
                    self.initWebview()
                    return
                }

				self.trakt.saveToken(token: token!)
				self.delegate?.TraktAuthViewControllerDidAuthenticate(controller: self)
            }
            return ()
        }
		decisionHandler(WKNavigationActionPolicy.allow)
    }

	public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error)
    }

	public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
}
