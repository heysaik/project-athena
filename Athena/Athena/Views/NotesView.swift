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
                                .font(.headline)
                        Spacer()
                    } else {
                        ScrollView {
                            ForEach(noteResults) { note in
                                NavigationLink {
                                    NotesDetailView(note: note)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(note.title)
                                            .foregroundColor(.white)
                                            .font(.system(.title3, design: .rounded).bold())
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(0)
                                        Text(note.note)
                                            .foregroundColor(.white)
                                            .font(.system(.body, design: .rounded))
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
                        NotesEditView(note: $newNote, creatingNewNote: true)
                    } label: {
                        Image(systemName: "plus")
                    }
                })
            }
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
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
            .onSubmit(of: .search) {
                Task {
                    
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

