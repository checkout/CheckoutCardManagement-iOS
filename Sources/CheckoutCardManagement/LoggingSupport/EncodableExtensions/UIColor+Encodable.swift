//
//  UIColor+Encodable.swift
//  
//
//  Created by Alex Ioja-Yang on 13/09/2022.
//

import UIKit

extension UIColor: Encodable {
    
    private enum CodingKeys: String, CodingKey {
        case hex
    }
    
    internal var hexString: String {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let cgColorInRGB = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil),
              let colorComponents = cgColorInRGB.components,
              colorComponents.count >= 3 else {
            return ""
        }
        let r = colorComponents[0]
        let g = colorComponents[1]
        let b = colorComponents[2]
        let a = cgColor.alpha
        
        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a * 255)))
        }
        
        return color
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hexString, forKey: .hex)
    }
}
