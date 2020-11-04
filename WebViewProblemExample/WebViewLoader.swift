import Foundation

class WebViewLoader {
    private(set) var isLoading = false

    func load(_ urlString: String, done: @escaping (Data?, HTTPURLResponse?) -> Void) {
        let url = URL(string: urlString)
        isLoading = true
        URLSession.shared.dataTask(with: url!, completionHandler: { [weak self] (data, response, error) -> Void in
            self?.isLoading = false
            if error != nil {
                gcd.async(.main, closure: { () -> Void in
                    done(nil, nil)
                })

                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                gcd.async(.main, closure: { () -> Void in
                    done(data, response)
                })
            } else {
                gcd.async(.main, closure: { () -> Void in
                    done(nil, nil)
                })
            }
        }).resume()
    }
}
