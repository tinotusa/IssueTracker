//
//  SFSymbol.swift
//  MacIssueTracker
//
//  Created by Tino on 18/1/2023.
//

import SwiftUI

/// Sf symbols used in the app.
enum SFSymbol: String, CaseIterable, Identifiable {
    case trash = "trash"
    case plus = "plus"
    case sidebarLeft = "sidebar.left"
    case squareAndPencil = "square.and.pencil"
    case rectangleAndPencilAndEllipsis = "rectangle.and.pencil.and.ellipsis"
    case pencil = "pencil"
    case pencilSlash = "pencil.slash"
    case book = "book"
    case bookClosed = "book.closed"
    
    /// A unique id of a case.
    var id: Self { self }
    
    /// The image of the sf symbol.
    var image: Image { Image(systemName: self.rawValue) }
}
    
