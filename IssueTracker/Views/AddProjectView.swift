//
//  AddProjectView.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI

struct AddProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView()
    }
}
