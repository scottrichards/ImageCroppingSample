//
//  UIImage+.swift
//  TruColoriOS
//
//  Created by Scott Richards on 11/30/21.
//

import Foundation
import UIKit


extension UIImage {
    
    /// Get the color of the pixel at the given point the point is expressed in pixels relative to the images size
    func getPixelColor(pos: CGPoint) -> UIColor? {

        guard let cgImage = self.cgImage, let cgDataProvider = cgImage.dataProvider else {
            return nil
        }
        let pixelData = cgDataProvider.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// Crop an image at the specified rect and return the cropped Image
    /// image -> image to be cropped
    /// rect -> rectangle in the images coordinates (pixels) not screen coordinates (points)
    func cropImage(rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        if let croppedCGImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedCGImage)
        } else {
            return nil
        }
    }

    /// Second way to crop an image
    /// rect -> rectangle in the images coordinates (pixels) not screen coordinates (points)
    /// let scale = imageView.frame.width/image.size.width
    func cropImage2(rect: CGRect, scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width / scale, height: rect.size.height / scale), true, 0.0)
        self.draw(at: CGPoint(x: -rect.origin.x / scale, y: -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
    
    func debugPrintOrientation() -> String {
        switch self.imageOrientation {
        case .up : return "up"
        case .upMirrored: return "upMirrored"
        case .down: return "down"
        case .downMirrored: return "downMirrored"
        case .left: return "left"
        case .leftMirrored: return "leftMirrored"
        case .right: return "right"
        case .rightMirrored: return "rightMirrored"
        }
    }
}
