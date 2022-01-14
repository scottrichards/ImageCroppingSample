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
    func cgImageCrop(rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        if let croppedCGImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedCGImage)
        } else {
            return nil
        }
    }

    /// Crop an image using ImageContext based on the aspect Ratio of the
    /// rect -> rectangle in the images coordinates (pixels) not screen coordinates (points)
    /// let scale = imageView.frame.width / image.size.width
    func imageContextCrop(rect: CGRect, scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width / scale, height: rect.size.height / scale), true, 0.0)
        self.draw(at: CGPoint(x: -rect.origin.x / scale, y: -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
    
    /// Crop an image using ImageContext based on the aspect Ratio of the
    /// rect -> rectangle in the images coordinates (pixels) not screen coordinates (points)
    /// let scale = imageView.frame.width / image.size.width
    func imageContextCrop(rect: CGRect, imageView: UIImageView) -> UIImage? {
        let scale = imageView.frame.width / self.size.width
        return imageContextCrop(rect: rect, scale: scale)
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
    
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
