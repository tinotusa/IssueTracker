//
//  TextStyles.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI

struct TextStyles: View {
    var body: some View {
        VStack {
            Text("Title style")
                .titleStyle()
            Text("Header")
                .headerStyle()
            Text("This is the body style.")
                .bodyStyle()
            Text("This is the footer style.")
                .footerStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.customBackground)

    }
}

/// Text styles for the app.
private struct TextStyle: ViewModifier {
    /// The fonts in the app.
    enum FontType {
        case courierNew
        case sfPro
        
        var fontName: String {
            switch self {
            case .courierNew: return "Courier New"
            case .sfPro: return "SFProText-Light"
            }
        }
    }
    
    private let size: Double
    private let font: FontType
    private let textStyle: Font.TextStyle
    
    init(size: Double, font: FontType = .sfPro, relativeTo textStyle: Font.TextStyle) {
        self.size = size
        self.font = font
        self.textStyle = textStyle
    }
    
    func body(content: Content) -> some View {
        content
            .font(.custom(font.fontName, size: size, relativeTo: textStyle))
    }
}


extension View {
    func titleStyle() -> some View {
        modifier(TextStyle(size: 30, font: .courierNew, relativeTo: .title))
            .fontWeight(.light)
            .foregroundColor(.text)
    }
    
    func headerStyle() -> some View {
        modifier(TextStyle(size: 25, relativeTo: .headline))
            .fontWeight(.light)
            .foregroundColor(.text)
    }
    
    func bodyStyle() -> some View {
        modifier(TextStyle(size: 18, relativeTo: .body))
            .fontWeight(.light)
            .foregroundColor(.text)
    }
    
    func buttonTextStyle() -> some View {
        modifier(TextStyle(size: 18, relativeTo: .body))
            .fontWeight(.light)
            .foregroundColor(.buttonText)
    }
    
    func footerStyle() -> some View {
        modifier(TextStyle(size: 12, relativeTo: .footnote))
            .fontWeight(.light)
            .foregroundColor(.customSecondary)
    }
}

struct TextStyles_Previews: PreviewProvider {
    static var previews: some View {
        TextStyles()
    }
}
