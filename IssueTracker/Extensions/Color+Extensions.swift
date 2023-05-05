//
//  Color+Extensions.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI

extension Color {
    static let customBackground = Color("customBackground")
    static let buttonBackground = Color("buttonBackground")
    static let buttonDisabled = Color("buttonDisabled")
    static let buttonTextDisabled = Color("buttonTextDisabled")
    static let buttonLabel = Color("buttonLabel")
    static let buttonLabelDisabled = Color("buttonLabelDisabled")
    static let buttonText = Color("buttonText")
    static let customSecondary = Color("customSecondary")
    static let deleteColour = Color("deleteColour")
    static let popup = Color("popup")
    static let tag = Color("tag")
    static let tagSelected = Color("tagSelected")
    static let tagUnselected = Color("tagUnselected")
    static let tagTextSelected = Color("tagTextSelected")
    static let tagTextUnselected = Color("tagTextUnselected")
    static let text = Color("text")
    
    /// Returns the rgb values of the color
    var hexValue: String {
        guard let components = UIColor(self).cgColor.components else {
            return "ffffff"
        }
        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        
        let redHex = String(red, radix: 16).leftPadding(toLength: 2, withPad: "0")
        let greenHex = String(green, radix: 16).leftPadding(toLength: 2, withPad: "0")
        let blueHex = String(blue, radix: 16).leftPadding(toLength: 2, withPad: "0")
        
        return "\(redHex)\(greenHex)\(blueHex)"
    }
    
    /// Returns the opacity value of the color
    var opacityValue: Double {
        guard let components = UIColor(self).cgColor.components else {
            return 1
        }
        return components[3]
    }
    
    init?(hex: String, opacity: Double = 1) {
        let hex = Array(hex)
        guard let red = Int(String(hex[..<2]), radix: 16) else {
            return nil
        }
        guard let green = Int(String(hex[2..<4]), radix: 16) else {
            return nil
        }
        guard let blue = Int(String(hex[4...]), radix: 16) else {
            return nil
        }
        self.init(
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0,
            opacity: opacity
        )
    }
}
