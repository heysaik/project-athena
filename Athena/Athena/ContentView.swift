//
//  ContentView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/6/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            Image(systemName: "book.fill")
                .font(.system(size: 50))
            Text("Welcome to Athena")
                .font(.system(.title, design: .rounded)).bold()
            Text("Athena is the app for book lovers around the world to help you keep track of your readings.")
                .font(.system(.title3, design: .rounded))
            Button("Next") {
                // Go to next screen
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
