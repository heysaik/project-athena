//
//  NotesEditView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import SwiftUI
import Firebase
import Foundation

struct NotesEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var note: Note
    
    var creatingNewNote = false
    private let firestore = Firestore.firestore()
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                TextField("Title", text: $note.title)
                    .font(.custom("FoundersGrotesk-Bold", size: 24))
                CustomTextEditor(placeholder: "Start typing..", text: $note.note)
                    .font(.custom("FoundersGrotesk-Regular", size: 17))
                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .body()
                }
            })
            
            ToolbarItem(placement: .primaryAction, content: {
                Button {
                    Task {
                        if creatingNewNote {
                            print("creating note")
                            try await createNote(note: note)
                            dismiss()
                        } else {
                            try await updateNote(note: note)
                            dismiss()
                        }
                    }
                } label: {
                    Text("Save")
                        .headline()
                }
            })
        }
        .navigationTitle("Edit Note")
    }
    
    func createNote(note: Note) async throws {
        do {
            try await firestore
                .collection("notes")
                .document()
                .setData([
                    "title": note.title,
                    "note": note.note,
                    "createdAt": note.createdAt,
                    "creatorID": note.creatorID,
                    "editedAt": note.editedAt
                ])
        } catch let addError {
            print(addError.localizedDescription)
        }
    }
    
    func updateNote(note: Note) async throws {
        do {
            if let noteId = note.id {
                try await firestore
                    .collection("notes")
                    .document(noteId)
                    .updateData([
                        "title": note.title,
                        "note": note.note,
                        "createdAt": note.createdAt,
                        "creatorID": note.creatorID,
                        "editedAt": note.editedAt
                    ])
            }
        } catch let addError {
            print(addError.localizedDescription)
        }
    }
    
    func dismiss(){
        self.presentationMode.wrappedValue.dismiss()
    }
}


struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    init(placeholder: String, text: Binding<String>) {
        UITextView.appearance().backgroundColor = .clear
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.primary.opacity(0.25))
            }
            
            TextEditor(text: $text)
        }
    }
}
