//
//  IssueTrackerApp.swift
//  IssueTracker
//
//  Created by Tino on 26/12/2022.
//

import SwiftUI
import CoreData

@main
struct IssueTrackerApp: App {
    @StateObject private var persistenceController: PersistenceController
    
    init() {
        let controller: PersistenceController
        if UITestingHelper.shouldAddPreveiwData {
            controller = .preview
        } else if UITestingHelper.isUITesting {
            controller = .init(inMemory: true)
        } else {
            controller = .shared
        }
        
        _persistenceController = StateObject(wrappedValue: controller)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(persistenceController)
        }
        .commands {
            IssueTrackerCommands()
        }
        #if os(macOS)
        Settings {
            IssueTrackerSettings()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        #endif
    }
}

struct IssueTrackerCommands: Commands {
    @FocusedBinding(\.selectedIssue) var selectedIssue
    @FocusedBinding(\.selectedProject) var selectedProject
    @FocusedValue(\.deleteIssueAction) var deleteIssueAction
    @FocusedValue(\.addIssueAction) var addIssueAction
    @FocusedValue(\.editIssueAction) var editIssueAction
    @FocusedValue(\.setIssueStatusAction) var setIssueStatusAction
    
    var body: some Commands {
        SidebarCommands()
        
        CommandMenu("IssueTracker") {
            Button("Add issue") {
                addIssueAction?()
            }
            .keyboardShortcut("n")
            .disabled(selectedIssue == nil)
            
            Button("Edit issue") {
                editIssueAction?()
            }
            .keyboardShortcut("e")
            .disabled(selectedIssue == nil)
            
            Divider()
            Button("Delete issue", role: .destructive) {
                if let selectedIssueKey = selectedIssue, let selectedIssue = selectedIssueKey {
                    deleteIssueAction?(selectedIssue)
                }
            }
            .keyboardShortcut(.delete)
            .disabled(selectedIssue == nil)
        }
    }
}

private struct SelectedIssue: FocusedValueKey {
    typealias Value = Binding<Issue?>
}

//  TODO: this seems like  it doesn't do anything
private struct SelectedProject: FocusedValueKey {
    typealias Value = Binding<Project?>
}

private struct DeleteIssueActionKey: FocusedValueKey {
    typealias Value = (Issue) -> Void
}

private struct AddIssueActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

private struct EditIssueActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

private struct SetIssueStatusActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

extension FocusedValues {
    var selectedIssue: Binding<Issue?>? {
        get { self[SelectedIssue.self] }
        set { self[SelectedIssue.self] = newValue }
    }
    
    var selectedProject: Binding<Project?>? {
        get { self[SelectedProject.self] }
        set { self[SelectedProject.self] = newValue }
    }
    
    var deleteIssueAction: ((Issue) -> Void)? {
        get { self[DeleteIssueActionKey.self] }
        set { self[DeleteIssueActionKey.self] = newValue }
    }
    
    var editIssueAction: (()-> Void)? {
        get { self[EditIssueActionKey.self] }
        set { self[EditIssueActionKey.self] = newValue }
    }
    
    var addIssueAction: (()-> Void)? {
        get { self[AddIssueActionKey.self] }
        set { self[AddIssueActionKey.self] = newValue }
    }
    
    var setIssueStatusAction: (() -> Void)? {
        get { self[SetIssueStatusActionKey.self] }
        set { self[SetIssueStatusActionKey.self] = newValue }
    }
}
