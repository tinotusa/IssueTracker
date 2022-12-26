//
//  IssueTrackerApp.swift
//  IssueTracker
//
//  Created by Tino on 26/12/2022.
//

import SwiftUI

@main
struct IssueTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
