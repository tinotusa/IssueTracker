//
//  TextStyles.swift
//  MacIssueTracker
//
//  Created by Tino on 21/1/2023.
//

import SwiftUI

struct TextStyles: View {
    var body: some View {
        VStack {
            Text("Title style")
                .titleStyle()
            Text("Body style")
                .bodyStyle()
        }
    }
}

struct TextStyle: ViewModifier {
    @ScaledMetric var size: Double
    
    func body(content: Content) -> some View {
        content
            .font(.custom("SFProText-Light", size: size))
    }
}

extension View {
    func bodyStyle() -> some View {
        modifier(TextStyle(size: 16))
    }
    
    func titleStyle() -> some View {
        modifier(TextStyle(size: 20))
    }
}

struct TextStyles_Previews: PreviewProvider {
    static var previews: some View {
        TextStyles()
    }
}
