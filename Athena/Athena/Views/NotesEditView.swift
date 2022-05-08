//
//  NotesEditView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import SwiftUI

struct NotesEditView: View {
    @State private var title = ""
    @State private var noteBody = ""

    var note: Note
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                TextField("Title", text: $title)
                    .font(.system(.title, design: .rounded).bold())
                CustomTextEditor(placeholder: "Start typing..", text: $noteBody)
                    .font(.body)
                Spacer()
            }
            .padding()
        }
        .onAppear {
            self.title = note.title
            self.noteBody = note.note
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button {
                    // Dismiss View
                } label: {
                    Text("Cancel")
                }
            })
            
            ToolbarItem(placement: .primaryAction, content: {
                Button {
                    // TODO: Save Title, Body, Update Book, and Edited At and then dismiss
                } label: {
                    Text("Save")
                }
            })
        }
        .navigationTitle("Edit Note")
    }
}


struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    let internalPadding: CGFloat = 5
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty  {
                Text(placeholder)
                    .foregroundColor(Color.primary.opacity(0.25))
                    .padding(EdgeInsets(top: 7, leading: 4, bottom: 0, trailing: 0))
                    .padding(internalPadding)
            }
            TextEditor(text: $text)
                .padding(internalPadding)
        }.onAppear() {
            UITextView.appearance().backgroundColor = .clear
        }.onDisappear() {
            UITextView.appearance().backgroundColor = nil
        }
    }
}
