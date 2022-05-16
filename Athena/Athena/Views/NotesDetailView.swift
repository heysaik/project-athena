//
//  NotesDetailView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import SwiftUI



struct NotesDetailView: View {
    var note: Note
   
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            
            // TODO: ADD BOOK VIEW HERE MAKE IT LOOK SIMILAR TO SEARCH RESULTS BOOK VIEW
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text(note.note)
                        .lineLimit(0)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .navigationTitle(note.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction, content: {
                NavigationLink {
                    NotesEditView(note: note)
                } label: {
                    Image(systemName: "pencil.circle")
                }
            })
        }
  
    }
}
