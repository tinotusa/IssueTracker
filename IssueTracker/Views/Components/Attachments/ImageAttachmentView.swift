//
//  ImageAttachmentView.swift
//  IssueTracker
//
//  Created by Tino on 18/3/2023.
//

import SwiftUI

struct ImageAttachmentView: View {
    let url: URL
    private let attachmentLoader = AttachmentLoader()
    @State private var loadingState: AttachmentLoadingState = .loading
    let size = 80.0
    
    var body: some View {
        Group {
            switch loadingState {
            case .loading:
                loadingView
            case .loaded(let assetURL):
                loadedView(assetURL: assetURL)
            case .urlNotFound:
                AttachmentLoadingErrorView(errorType: .notFound)
            case .error:
                AttachmentLoadingErrorView(errorType: .error)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Views
private extension ImageAttachmentView {
    var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .onAppear {
                Task {
                    do {
                        loadingState = .loading
                        guard let imageURL = try await attachmentLoader.getAttachmentAssetURL(fromURL: url) else {
                            loadingState = .urlNotFound
                            return
                        }
                        loadingState = .loaded(url: imageURL)
                    } catch {
                        loadingState = .error(error: error)
                    }
                }
            }
    }
    
    func loadedView(assetURL: URL) -> some View {
        NavigationLink(value: assetURL) {
            AsyncImage(url: assetURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .cornerRadius(10)
        }
    }
    
}

struct ImageAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: Change this url for testing
        ImageAttachmentView(url: URL(string: "google.com")!)
    }
}
