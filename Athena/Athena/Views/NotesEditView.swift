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
    @State private var title = ""
    @State private var noteBody = ""
    @State private var createdAt  = Date()
    @State private var createrID = ""
    @State private var editedAt = Date()
     
    var note: Note
    private let firestore =  Firestore.firestore()
    @State private var oldNotes = [Note]()
    // var title: ""  var note: ""  var createdAt: ""  var creatorID: ""  var editedAt: ""
//    @State private var note: Note = Note(id: "",title: "" , note: "" , createdAt: Date(), creatorID: "" , editedAt: Date())
    func addNote(note: Note){
        do{
//            let _ = try firestore.collection("note").addDocument(from: note)
            let _ = try Firestore.firestore()
                .collection("notes")
                .addDocument(from:note)    // note.id for updatinga note in ()
           
                 .setData([ "title": self.title, "note": self.noteBody, "createdAt": self.createdAt, "createrID": self.createrID, "editedAt": self.editedAt])
    //        }

        }
        catch{
            print(error)
        }
    }
    func save(){
      addNote(note : note)
    }
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
            self.createdAt = note.createdAt
            self.createrID = note.creatorID
            self.editedAt = note.editedAt
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button (
                    // Dismiss View
                    action: {handleDoneTapped()}
                , label: {
                    Text("Cancel")
                })
            })
            
            ToolbarItem(placement: .primaryAction, content: {
                Button (
                    // TODO: Save Title, Body, Update Book, and Edited At and then dismiss
                    action: {handleDoneTapped()}
                    
                ,label: {
                    Text("Save")
                })
            })
        }
        .navigationTitle("Edit Note")
    }
    func handleCancelTapped() {
        dismiss()
    }
    
    func handleDoneTapped(){

//        let noteref = Firestore.firestore()
//            .collection("notes")
//            .document()    // note.id for updatinga note in ()
//
//        noteref.setData([ "title": self.title, "note": self.noteBody, "createdAt": self.createdAt, "createrID": self.createrID, "editedAt": self.editedAt])
////        }
        self.save()
        dismiss()
    }
    func dismiss(){
        presentationMode.wrappedValue.dismiss()
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
