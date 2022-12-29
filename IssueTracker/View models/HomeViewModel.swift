//
//  HomeViewModel.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import os
import SwiftUI
import CoreData

final class HomeViewModel: ObservableObject {
    let title: LocalizedStringKey = "Projects"
    @Published var showingAddProjectView = false
    @Published var showingEditProjectView = false
    let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "HomeViewModel")
}
