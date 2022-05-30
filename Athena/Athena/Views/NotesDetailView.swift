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
            
            VStack(alignment: .leading, spacing: 8) {
                ScrollView {
                    Text(note.note)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                if note.book != nil {
                    HStack(spacing: 16) {
                        BookCoverView(imageURLString: note.book!.imageLink, size: 100)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(note.book!.title)
                                .titleThree()
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            Text(note.book!.authors.formatted(.list(type: .and)))
                                .body()
                                .italic()
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .opacity(0.8)
                            Text(note.book!.description)
                                .caption()
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.black.opacity(0.25))
                    )
                }
            }
            .padding()
        }
        .navigationTitle(note.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction, content: {
                NavigationLink {
                    TextEditView(note: $note, book: .constant(Book(id: "", docID: "", title: "", authors: [], publisher: "", publishedDate: "", description: "", pageCount: 0, categories: [], imageLink: "")),contentType: .note, actionType: .update)
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
