//
//  ContentView.swift
//  IssueTracker
//
//  Created by Tino on 26/12/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext
        )
    }
}
