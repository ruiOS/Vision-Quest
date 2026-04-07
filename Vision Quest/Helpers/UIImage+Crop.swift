//
//  UIImage+Crop.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit

extension UIImage {
    
    /// Crops the image using a normalized coordinate system normalizedRect [0, 0, 1, 1], with Vision origins at the bottom-left.
    func cropped(to normalizedRect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        // cgImage width and height are in absolute pixels.
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        let x = normalizedRect.origin.x * imageWidth
        // Vision Y starts from bottom edge, CoreGraphics starts from top.
        let invertedY = 1.0 - normalizedRect.origin.y - normalizedRect.size.height
        let y = invertedY * imageHeight
        
        let width = normalizedRect.size.width * imageWidth
        let height = normalizedRect.size.height * imageHeight
        
        let cropRect = CGRect(x: x, y: y, width: width, height: height)
        
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
        }
        
        return nil
    }
}
