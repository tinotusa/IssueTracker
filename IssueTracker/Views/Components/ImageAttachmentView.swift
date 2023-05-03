//
//  ImageAttachmentView.swift
//  IssueTracker
//
//  Created by Tino on 18/3/2023.
//

import SwiftUI

struct ImageAttachmentView: View {
    let url: URL
    @State private var imageURL: URL?
    private let attachmentLoader = AttachmentLoader()
    
    var body: some View {
        Group {
            if let imageURL {
                NavigationLink(value: imageURL) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(10)
        .onAppear {
            Task {
                do {
                    imageURL = try await attachmentLoader.getAttachmentAssetURL(fromURL: url)
                } catch {
                    // TODO: add some logic here.
                }
            }
        }
    }
}

struct ImageAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: Change this url for testing
        ImageAttachmentView(url: URL(string: "google.com")!)
    }
}
