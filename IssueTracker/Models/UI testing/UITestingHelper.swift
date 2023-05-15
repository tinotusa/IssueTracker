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
    
    static var addIssueViewThrowsError: Bool {
        let shouldThrow = ProcessInfo.processInfo.environment["addIssueViewThrowsError"]
        guard let shouldThrow else {
            return false
        }
        return shouldThrow == "true"
    }
    
    static var shouldAddPreveiwData: Bool {
        return CommandLine.arguments.contains(CommandLineArgument.addPreviewData)
    }
}
