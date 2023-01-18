//
// Color+rgbComponents.swift
//  MacIssueTracker
//
//  Created by Tino on 18/1/2023.
//

import SwiftUI

extension Color {
    /// Returns the rgb values of the color
    var rgbComponents: (r: Double, g: Double, b: Double) {
        guard let components = NSColor(self).cgColor.components else {
            return (r: 0, g: 0, b: 0)
        }
        let red = Double(components[0])
        let green = Double(components[1])
        let blue = Double(components[2])
        
        return (r: red, g: green, b: blue)
    }
    
    /// Returns the opacity value of the color
    var opacityValue: Double {
        guard let components = NSColor(self).cgColor.components else {
            return 1
        }
        return components[3]
    }
}
