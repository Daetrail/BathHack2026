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

func makeJPEGData(from image: UIImage) throws -> Data {
    guard let data = image.jpegData(compressionQuality: 0.85) else {
        throw ImageConversionError.failedToMakeJPEGImage
    }
    
    return data
}
