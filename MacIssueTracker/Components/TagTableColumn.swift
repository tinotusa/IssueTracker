//
//  TagTableColumn.swift
//  MacIssueTracker
//
//  Created by Tino on 25/1/2023.
//

import SwiftUI

struct TagTableColumn: View {
    @ObservedObject var tag: Tag
    @State private var selectedColour = Color.green
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack {
            ColorPicker("Tag Colour", selection: $selectedColour)
                .labelsHidden()
            Text(tag.name)
        }
        .onAppear {
            let colour = Color(red: tag.red, green: tag.green, blue: tag.blue, opacity: tag.opacity)
            selectedColour = colour
        }
        .onChange(of: selectedColour) { colour in
            // TODO: make rgb have alpha component?
            let components = colour.rgbComponents
            tag.red = components.r
            tag.green = components.g
            tag.blue = components.b
            tag.opacity = colour.opacityValue
            try? viewContext.save()
        }
    }
}

struct TagTableColumn_Previews: PreviewProvider {
    static var viewContext = PersistenceController.tagsPreview.container.viewContext
    static var previews: some View {
        TagTableColumn(tag: .init(name: "testing", context: viewContext))
            .environment(\.managedObjectContext, viewContext)
    }
}
