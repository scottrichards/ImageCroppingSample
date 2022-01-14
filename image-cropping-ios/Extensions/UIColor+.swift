//
//  UIColor+.swift
//  image-cropping-ios
//
//  Created by Scott Richards on 1/14/22.
//  Copyright © 2022 服部穣. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    func hexStringFromColor() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        print(hexString)
        return hexString
     }
    
    func getRed() -> Float {
        let components = self.cgColor.components
        let red = components?[0] ?? 0.0
        return Float(red)
    }

    func getBlue() -> Float {
        let components = self.cgColor.components
        let blue: CGFloat = components?[2] ?? 0.0
        return Float(blue)
    }

    func getGreen() -> Float {
        let components = self.cgColor.components
        let green: CGFloat = components?[1] ?? 0.0
        return  Float(green)
    }

    convenience init(byteWhite white: CGFloat, alpha: CGFloat = 1.0) {
        self.init(white: white / 255.0, alpha: alpha)
    }
    
    convenience init(byteRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    class func byte(white: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(white: white / 255.0, alpha: alpha)
    }
    
    class func byte(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    /**
     Create a UIColor from a 6 character hex string with an optional '#' prefix. Optional alpha component is defaulted to 1.0.
     - parameters:
     - hexString: A six character hex representation of a color with or without a leading '#' character.
     - alpha: Optional alpha value for the color. Defaults to 1.0.
     */
    @objc convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        guard hexString.count == 6 || (hexString.count == 7 && hexString.hasPrefix("#")) else {
            return nil
        }
        
        var hexInt: UInt32 = 0
        
        let scanner: Scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        
        if !scanner.scanHexInt32(&hexInt) {
            return nil
        }
        
        let red = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xff) >> 0) / 255.0
        let alpha = alpha
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

}
