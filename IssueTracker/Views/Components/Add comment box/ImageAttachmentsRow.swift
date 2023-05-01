//
//  ImageAttachmentsRow.swift
//  IssueTracker
//
//  Created by Tino on 29/4/2023.
//

import SwiftUI

struct ImageAttachmentsRow: View {
    let images: [Image]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0 ..< images.count, id: \.self) { index in
                    previewImage(images[index])
                }
            }
        }
    }
}

private extension ImageAttachmentsRow {
    enum Constants {
        static let size = 100.0
        static let cornerRadius = 10.0
    }
    
    func previewImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: Constants.size, height: Constants.size)
            .cornerRadius(Constants.cornerRadius)
    }
}

struct ImageAttachmentsRow_Previews: PreviewProvider {
    static var previews: some View {
        ImageAttachmentsRow(images: [])
    }
}
