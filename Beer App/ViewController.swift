import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!

    override func loadView() {
        // Initialize the WKWebView
        webView = WKWebView()
        webView.navigationDelegate = self // Set the delegate
        
        // Disable scrolling
        webView.scrollView.isScrollEnabled = false
        
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the local HTML file
        if let url = Bundle.main.url(forResource: "calc2", withExtension: "html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    // Handle navigation errors
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError(message: "Failed to load content. Please try again.")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showError(message: "Failed to load content. Please check if the file is available.")
    }

    // Helper method to show an error alert
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
