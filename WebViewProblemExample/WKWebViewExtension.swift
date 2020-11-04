import WebKit

extension WKWebView {
    @discardableResult
    func evaluateJavaScriptSync(from script: String) -> String? {
        var result: String?
        var keppAlive = true

        self.evaluateJavaScript(script, completionHandler: { (html, _) in
            if let html = html as? String {
                result = html
            } else if let html = html as? Double {
                result = html.description
            }
            keppAlive = false
        })

        let runLoop = RunLoop.current
        while keppAlive && runLoop.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 0.1)) {}

        return result
    }
}
