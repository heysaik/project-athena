//
//  NotesDetailView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import SwiftUI
import FirebaseFirestore

struct NotesDetailView: View {
    @State private var note: Note = Note(title: "", note: "", createdAt: Date(), creatorID: "", editedAt: Date())
    @State private var showDeleteAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    private let firestore = Firestore.firestore()
    
    init(note: Note) {
        self._note = State(wrappedValue: note)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            
            // TODO: ADD BOOK VIEW HERE MAKE IT LOOK SIMILAR TO SEARCH RESULTS BOOK VIEW
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text(note.note)
                        .lineLimit(0)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
        }
        .navigationTitle(note.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction, content: {
                NavigationLink {
                    NotesEditView(note: $note, creatingNewNote: false)
                } label: {
                    Image(systemName: "pencil")
                }
            })
            
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button {
                    showDeleteAlert.toggle()
                } label: {
                    Image(systemName: "trash")
                }
            })
        }
        .alert(Text("Are you sure"), isPresented: $showDeleteAlert) {
            Button(role: .cancel) {
                showDeleteAlert.toggle()
            } label: {
                Text("Cancel")
            }
            
            Button(role: .destructive) {
                Task {
                    if let noteID = note.id {
                        try await firestore
                            .collection("notes")
                            .document(noteID)
                            .delete()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            } label: {
                Text("Delete")
            }
        } message: {
            Text("Your note will be deleted from Athena. This action is irreversible.")
        }

    }
}
