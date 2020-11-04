import UIKit
import WebKit

class ExampleWebViewController: UIViewController {
    var exampleWebView: ExampleWebView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        exampleWebView = ExampleWebView(frame: UIApplication.shared.windows.first!.frame)

        view.addSubview(exampleWebView)

        exampleWebView.load("https://www.google.com")

    }
}
