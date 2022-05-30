//
//  NotesView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/13/22.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase
import Foundation

struct NotesView: View {
    @State private var noteResults = [Note]()
    @State private var searchTerm = ""
    @State private var newNote = Note(title: "", note: "", createdAt: Date(), creatorID: Auth.auth().currentUser!.uid, editedAt: Date())
    
    private let firestore = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if noteResults.count == 0 {
                        Spacer()
                        Text("You have no notes")
                            .headline()
                        Spacer()
                    } else {
                        ScrollView {
                            ForEach(searchTerm.isEmpty ? noteResults : noteResults.filter { $0.title.lowercased().contains(searchTerm.lowercased()) || $0.note.lowercased().contains(searchTerm.lowercased()) || (($0.book?.title.lowercased().contains(searchTerm.lowercased())) == true) || (($0.book?.authors.contains { $0.lowercased().contains(searchTerm.lowercased()) }) == true)}) { note in
                                NavigationLink {
                                    NotesDetailView(note: note)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(note.title)
                                            .titleThree()
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(0)
                                        Text(note.note)
                                            .body()
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                        Divider()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                    NavigationLink {
                        TextEditView(note: $newNote, book: .constant(Book(id: "", docID: "", title: "", authors: [], publisher: "", publishedDate: "", description: "", pageCount: 0, categories: [], imageLink: "")), contentType: .note, actionType: .create)
                    } label: {
                        Image(systemName: "plus")
                    }
                })
            }
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for Titles, Books, or Content")
            .onAppear {
                Firestore.firestore()
                    .collection("notes")
                    .whereField("creatorID", isEqualTo: Auth.auth().currentUser!.uid)
                    .order(by: "editedAt", descending: true)
                    .addSnapshotListener { querySnapshot, error in
                        guard let snapshot = querySnapshot else {
                            print("Error fetching snapshots: \(error!)")
                            return
                        }
                        
                        var newNotes = [Note]()
                        for document in snapshot.documents {
                            do {
                                let document = try document.data(as: Note.self)
                                newNotes.append(document)
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }
                        newNotes.sort(by: {$0.editedAt > $1.editedAt})
                        self.noteResults = newNotes
                    }
            }
        }
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView()
    }
}

