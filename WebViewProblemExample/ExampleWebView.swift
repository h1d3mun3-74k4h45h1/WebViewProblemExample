import UIKit
import WebKit

class ExampleWebView: UIView {
    var webView: WKWebView

    let webViewLoader = WebViewLoader()

    override init(frame: CGRect) {
        webView = WKWebView(frame: .zero)
        super.init(frame: frame)

        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.showsVerticalScrollIndicator = false

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        webView = WKWebView(frame: .zero)
        super.init(coder: aDecoder)

        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.showsVerticalScrollIndicator = false

        setup()
    }

    fileprivate func setup() {
        addSubview(webView)

        webView.frame = UIApplication.shared.windows.first!.frame
    }

    func load(_ urlString: String) {
        if webViewLoader.isLoading {
            return
        }
        webViewLoader.load(
            urlString,
            done: { [weak self] data, response in
                guard let `self` = self else { return }
                if
                    let data = data,
                    let response = response,
                    let mimeType = response.mimeType,
                    let textEncodingName = response.textEncodingName,
                    let url = response.url
                {
                    self.webView.load(data, mimeType: mimeType, characterEncodingName: textEncodingName, baseURL: url)
                } else {
                    print("failed!!!!")
                }
            }
        )
    }
}

extension ExampleWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setupContentsHeight()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error)
    }

    func setupContentsHeight() {
        let heightString = webView.evaluateJavaScriptSync(from: "document.body.offsetHeight")
        if let heightString = heightString, let height = NumberFormatter().number(from: heightString) {
            print("succeed! height is \(CGFloat(truncating: height))")
            webView.isHidden = false
        } else {
            print("failed!!!")
        }
    }
}
