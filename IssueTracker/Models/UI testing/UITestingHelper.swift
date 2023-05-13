//
//  UITestingHelper.swift
//  IssueTracker
//
//  Created by Tino on 12/5/2023.
//

import Foundation

enum UITestingHelper {
    static var isUITesting: Bool {
        CommandLine.arguments.contains(CommandLineArgument.uiTesting)
    }
}
