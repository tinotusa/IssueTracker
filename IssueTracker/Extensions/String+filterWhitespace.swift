//
//  String+filterWhitespace.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import Foundation

extension String {
    /// Removes multiple whitespaces and replaces it with one.
    ///
    /// ```
    /// let text = " Hello,    world!  "
    /// let filteredText = text.filterWhitespace // "hello, world"
    /// ```
    ///
    /// - Returns: The filtered string.
    func filterWhitespace() -> Self {
        self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty}
            .joined(separator: " ")
    }
}
