//
//  CachedAsyncImage.swift
//  BathHack2026
//
//  Drop-in replacement for AsyncImage that caches downloaded images
//  in memory so they load instantly on revisit.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: UIImage?

    var body: some View {
        if let image {
            content(Image(uiImage: image))
        } else if url != nil {
            placeholder()
                .task(id: url) {
                    await loadImage()
                }
        } else {
            placeholder()
        }
    }

    private func loadImage() async {
        guard let url else { return }

        // Check cache first
        if let cached = ImageCache.shared.get(for: url) {
            self.image = cached
            return
        }

        // Download
        do {
            var request = URLRequest(url: url)
            request.setValue("true", forHTTPHeaderField: "ngrok-skip-browser-warning")
            let (data, _) = try await URLSession.shared.data(for: request)
            if let downloaded = UIImage(data: data) {
                ImageCache.shared.set(downloaded, for: url)
                self.image = downloaded
            }
        } catch {
            // Silently fail — placeholder stays visible
        }
    }
}

/// Simple in-memory image cache backed by NSCache.
final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        // Keep up to ~50MB of images in memory
        cache.totalCostLimit = 50 * 1024 * 1024
    }

    func get(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func set(_ image: UIImage, for url: URL) {
        let cost = image.jpegData(compressionQuality: 1)?.count ?? 0
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
}
