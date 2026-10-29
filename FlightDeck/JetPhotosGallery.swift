import SwiftUI
import UIKit
import WebKit

/// Loads JetPhotos as a first-party page in WebKit instead of scraping its
/// image URLs with URLSession, which JetPhotos can block as an automated request.
struct JetPhotosGallery: UIViewRepresentable {
    let registration: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.035, green: 0.075, blue: 0.12, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.load(URLRequest(url: JetPhotos.url(for: registration)))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let pageURL = JetPhotos.url(for: registration)
        guard webView.url != pageURL else { return }
        webView.load(URLRequest(url: pageURL))
    }
}

