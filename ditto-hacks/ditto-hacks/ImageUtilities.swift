//
//  ImageUtilities.swift
//  ditto-hacks
//
//  Helper utilities for image processing
//

import UIKit
import Foundation

struct ImageUtilities {
    
    /// Prepares an image for upload by resizing and converting to base64
    /// - Parameters:
    ///   - image: The UIImage to process
    ///   - maxDimension: Maximum width or height (will maintain aspect ratio)
    ///   - compressionQuality: JPEG compression quality (0.0 to 1.0)
    /// - Returns: Base64 encoded string of the processed image, or nil if processing fails
    static func prepareImageForUpload(
        image: UIImage,
        maxDimension: CGFloat = 1024,
        compressionQuality: CGFloat = 0.7
    ) -> String? {
        // Resize the image
        let resizedImage = resizeImage(image: image, maxDimension: maxDimension)
        
        // Convert to JPEG data
        guard let imageData = resizedImage.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        // Convert to base64
        return imageData.base64EncodedString()
    }
    
    /// Resizes an image to fit within the specified maximum dimension while maintaining aspect ratio
    /// - Parameters:
    ///   - image: The image to resize
    ///   - maxDimension: Maximum width or height
    /// - Returns: Resized UIImage
    static func resizeImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        
        // Check if resizing is needed
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let ratio = max(size.width, size.height) / maxDimension
        let newSize = CGSize(width: size.width / ratio, height: size.height / ratio)
        
        // Resize
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    
    /// Converts a base64 string back to a UIImage
    /// - Parameter base64String: The base64 encoded image string
    /// - Returns: UIImage if conversion is successful, nil otherwise
    static func imageFromBase64(base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    /// Compresses an image to approximately fit within a target size in bytes
    /// - Parameters:
    ///   - image: The image to compress
    ///   - targetSizeInBytes: Target size in bytes
    /// - Returns: Compressed image data, or nil if compression fails
    static func compressImage(image: UIImage, targetSizeInBytes: Int) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)
        
        // Iteratively reduce compression quality until we reach target size
        while let data = imageData, data.count > targetSizeInBytes && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
}
// MARK: - UIImage Extensions
extension UIImage {
    /// Returns a human-readable string representation of the JPEG image size
    /// - Parameter compressionQuality: JPEG compression quality (0.0 to 1.0)
    /// - Returns: Formatted string like "1.2 MB" or "450 KB"
    func jpegSizeString(compressionQuality: CGFloat = 0.7) -> String {
        guard let data = self.jpegData(compressionQuality: compressionQuality) else {
            return "Unknown"
        }
        
        let bytes = data.count
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

