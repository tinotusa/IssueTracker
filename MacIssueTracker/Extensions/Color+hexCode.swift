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
    
    /// Creates a colour from a hex string.
    ///
    /// ```
    /// let color = Color(hex: "#ff00ff", opacity: 0.5)
    /// ```
    ///
    /// - Parameters:
    ///   - hex: The hex value as a string.
    ///   - opacity: The opacity of the colour.
    init?(hex: String, opacity: Double = 1) {
        let hex = hex.filter { letter in
            let allowedCharacters = Set("0123456789abcdef")
            return allowedCharacters.contains(letter)
        }
        guard opacity >= 0 && opacity <= 1 else { return nil }
        guard hex.count == 6 else { return nil }
        guard let hexValue = Int(hex, radix: 16) else {
            return nil
        }
        let red = Double(0xff & (hexValue >> 16) / 255)
        let green = Double(0xff & (hexValue >> 8) / 255)
        let blue = Double(0xff & (hexValue >> 0) / 255)
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
