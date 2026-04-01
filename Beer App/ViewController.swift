import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    var webView: WKWebView!

    private let totalKey = "savedTotal"
    private let dateKey = "savedDate"
    private let startTimeKey = "savedStartTime"

    override func loadView() {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(self, name: "saveDrinks")
        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false

        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = Bundle.main.url(forResource: "calc2", withExtension: "html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "saveDrinks")
    }

    // Called by JS when the total changes — save total and session start time to UserDefaults
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "saveDrinks",
              let body = message.body as? [String: Any],
              let total = body["total"] as? Double else { return }
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        UserDefaults.standard.set(total, forKey: totalKey)
        UserDefaults.standard.set(today, forKey: dateKey)
        if let startTime = body["startTime"] as? String {
            UserDefaults.standard.set(startTime, forKey: startTimeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: startTimeKey)
        }
    }

    // After page loads, inject the saved total and session start time if they're from today
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let savedDate = UserDefaults.standard.string(forKey: dateKey) ?? ""
        if savedDate == today {
            let savedTotal = UserDefaults.standard.double(forKey: totalKey)
            webView.evaluateJavaScript("setTotalDrinks(\(savedTotal))", completionHandler: nil)
            if let startTime = UserDefaults.standard.string(forKey: startTimeKey) {
                webView.evaluateJavaScript("setSessionStart('\(startTime)')", completionHandler: nil)
            }
        }
    }

    // Handle navigation errors
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError(message: "Failed to load content. Please try again.")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showError(message: "Failed to load content. Please check if the file is available.")
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
