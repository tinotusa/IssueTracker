//
//  ContentView.swift
//  MacIssueTracker
//
//  Created by Tino on 16/1/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ProjectListView()
            
            Text("Select a project.")
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    #if os(macOS)
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                    #endif
                } label: {
                    Label("Show sidebar", systemImage: "sidebar.leading")
                }
            }
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.projectsPreview.container.viewContext)
    }
}
