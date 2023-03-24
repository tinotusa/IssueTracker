//
//  ImageDetailView.swift
//  IssueTracker
//
//  Created by Tino on 20/3/2023.
//

import SwiftUI

struct ImageDetailView: View {
    let url: URL
    @GestureState private var magnifyBy = 1.0
    
    var body: some View {
        VStack {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(magnifyBy)
                    .gesture(magnificationGesture)
            } placeholder: {
                ProgressView()
            }
        }
    }
}

private extension ImageDetailView {
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { currentState, gestureState, transaction in
                gestureState = currentState
            }
    }
    
}

struct ImageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ImageDetailView(url: .previewImage)
    }
}
