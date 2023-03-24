//
//  URL+previewImage.swift
//  IssueTracker
//
//  Created by Tino on 24/3/2023.
//

import Foundation

extension URL {
    static var previewImage: Self {
        guard let url = Bundle.main.url(forResource: "bulbasaur", withExtension: "png") else {
            fatalError("Failed to get bulbasaur url.")
        }
        return url
    }
}
