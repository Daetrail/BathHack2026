//
//  MakeJPEGData.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 29/03/2026.
//

import UIKit

enum ImageConversionError: Error {
    case failedToMakeJPEGImage
}

/// Max pixel dimension for uploaded images — keeps file size small
/// while still looking sharp on Retina displays at 200pt height.
private let maxImageDimension: CGFloat = 800

func makeJPEGData(from image: UIImage) throws -> Data {
    let resized = downsized(image)
    guard let data = resized.jpegData(compressionQuality: 0.5) else {
        throw ImageConversionError.failedToMakeJPEGImage
    }
    return data
}

/// Resize the image so its longest side is at most `maxImageDimension`.
/// Returns the original if it's already small enough.
private func downsized(_ image: UIImage) -> UIImage {
    let size = image.size
    guard max(size.width, size.height) > maxImageDimension else { return image }

    let scale: CGFloat
    if size.width > size.height {
        scale = maxImageDimension / size.width
    } else {
        scale = maxImageDimension / size.height
    }

    let newSize = CGSize(width: size.width * scale, height: size.height * scale)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
    }
}
