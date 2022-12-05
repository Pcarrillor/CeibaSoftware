//
//  ContentView.swift
//  Ceiba Software
//
//  Created by Admin on 3/12/22.
//

import SwiftUI

struct ContentView: View {
    let persistence = CoreDataViewModel()
    var body: some View {
        VStack {
            UserListView().environment(\.managedObjectContext, persistence.container.viewContext)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
