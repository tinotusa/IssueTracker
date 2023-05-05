//
//  String+extensions.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import Foundation

extension String {
    /// Generates random Lorem ipsum text.
    /// - Parameter length: The number of words in the text.
    /// - Returns: The lorem ipsum text.
    static func generateLorem(ofLength length: Int = 5) -> String {
        let loremWords = """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent rhoncus ligula eget
            velit semper scelerisque. Ut augue sem, elementum eget dui at, dignissim vulputate leo. Phasellus
            eget sagittis metus, eu ullamcorper erat. Morbi sed efficitur est, et sollicitudin turpis. Donec
            vulputate molestie iaculis. Aenean ornare tellus et urna placerat laoreet. Donec diam tortor,
            fringilla eget euismod a, mollis eget tellus. Ut ante ligula, malesuada eu massa in, finibus
            interdum dolor.
        """
            .components(separatedBy: .whitespaces.union(.punctuationCharacters))
            .map{ $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let lorem = Set(loremWords)
        var words = [String]()
        
        for _ in 0 ..< length {
            let randomWord = String(lorem.randomElement() ?? "")
            words.append(randomWord)
        }
        
        return words.joined(separator: " ").capitalizedFirstLetter()
    }
    
    /// Caplitalizes the first letter of the string.
    /// - Returns: The string with the first letter capitalized.
    func capitalizedFirstLetter() -> Self {
        if self.isEmpty { return self }
        let firstLetter = self[startIndex].uppercased()
        return firstLetter + self[self.index(after: startIndex)...]
    }
    
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
    
    func leftPadding(toLength length: Int, withPad paddingCharacter: Character) -> Self {
        if self.count < length {
            return String(repeating: paddingCharacter, count: length - self.count) + self
        }
        return self
    }
}
