//
//  UIFont+Encodable.swift
//  
//
//  Created by Alex Ioja-Yang on 13/09/2022.
//

import UIKit

extension UIFont: Encodable {

    private enum CodingKeys: String, CodingKey {
        case name, weight, size
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fontName, forKey: .name)
        try container.encode(Int(pointSize), forKey: .size)

        if let fontFace = fontDescriptor.object(forKey: .face) as? String {
            try container.encode(fontFace, forKey: .weight)
        }
    }
}
