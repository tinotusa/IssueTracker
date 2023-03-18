//
//  ImageAttachmentView.swift
//  IssueTracker
//
//  Created by Tino on 18/3/2023.
//

import SwiftUI
import CloudKit

struct ImageAttachmentView: View {
    let url: URL
    @State private var imageURL: URL?
    
    var body: some View {
        Group {
            if let imageURL {
                AsyncImage(url: imageURL)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(10)
        .onAppear {
            loadImageAttachment()
        }
    }
}

private extension ImageAttachmentView {
    func loadImageAttachment() {
        let query = CKQuery(
            recordType: "Attachment",
            predicate: .init(format: "attachmentURL == %@", url.absoluteString)
        )
        
        var imageURL: URL?
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        operation.recordMatchedBlock = { id, result in
            switch result {
            case .failure(let error):
                print("Error failed to get asset: \(error)")
            case .success(let record):
                guard let asset = record["attachment"] as? CKAsset,
                      let url = asset.fileURL
                else {
                    print("failed to get asset or url")
                    return
                }
                imageURL = url
            }
        }
        operation.queryResultBlock = { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.imageURL = imageURL
                }
            case .failure(let error):
                print(error)
            }
        }
        let database = CKContainer.default().privateCloudDatabase
        database.add(operation)
    }
}

struct ImageAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: Change this url for testing
        ImageAttachmentView(url: URL(string: "google.com")!)
    }
}
