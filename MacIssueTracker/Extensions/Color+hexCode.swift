//
//  Color+hexCode.swift
//  MacIssueTracker
//
//  Created by Tino on 18/1/2023.
//

import SwiftUI

extension Color {
    /// Returns the hex value of the color
    var hexCode: Int {
        guard let components = NSColor(self).cgColor.components else {
            return 0xffffff
        }
        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        
        var hexValue = red
        hexValue <<= 8
        hexValue |= green
        hexValue <<= 8
        hexValue |= blue
        
        return hexValue
    }
    
    /// Returns the opacity value of the color
    var opacityValue: Double {
        guard let components = NSColor(self).cgColor.components else {
            return 1
        }
        return components[3]
    }
}
