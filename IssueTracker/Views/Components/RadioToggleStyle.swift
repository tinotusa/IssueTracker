//
//  RadioToggleStyle.swift
//  IssueTracker
//
//  Created by Tino on 28/4/2023.
//

import SwiftUI

struct RadioToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? SFSymbol.largeCircleFillCircle : SFSymbol.circle)
                .font(.title)
                .animation(.default, value: configuration.isOn)
        }
        .buttonStyle(.plain)
    }
}

extension ToggleStyle where Self == RadioToggleStyle {
    static var radioButton: RadioToggleStyle {
        RadioToggleStyle()
    }
}
