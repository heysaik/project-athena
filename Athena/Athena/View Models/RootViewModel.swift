//
//  RootViewModel.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class RootViewModel: NSObject, ObservableObject {
    @Published var currentlyReadingBooks = [Book]()
    @Published var wishlistedBooks = [Book]()
    @Published var alreadyReadBooks = [Book]()
    @Published var searchHistory = [SearchTerm]()
    @Published var myNotes = [Note]()

    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    override init() {
        super.init()
        
        Task {
            await loadCurrentlyReadingBooks()
            await loadWishlistedBooks()
            await loadAlreadyReadBooks()
            await loadSearchHistory()
            await loadMyNotes()
        }
    }
    
    // MARK: Private Functions
    private func loadCurrentlyReadingBooks() {
        if let user = auth.currentUser {
            // Get books in currently reading
            firestore
                .collection("currentlyReading")
                .whereField("readerID", isEqualTo: user.uid)
                .addSnapshotListener { querySnapshot, error in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    if let snapshot = querySnapshot {
                        let docs = snapshot.documents
                        self.currentlyReadingBooks = []
                        for doc in docs {
                            do {
                                let book = try doc.data(as: Book.self)
                                self.currentlyReadingBooks.append(book)
                            } catch let convertError {
                                print("Conversion Error: \(convertError.localizedDescription)")
                            }
                        }
                    }
                }
        }
    }
    
    private func loadWishlistedBooks() {
        if let user = auth.currentUser {
            // Load Wishlist
            firestore
                .collection("wishlist")
                .whereField("readerID", isEqualTo: user.uid)
                .addSnapshotListener { querySnapshot, error in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    if let snapshot = querySnapshot {
                        let docs = snapshot.documents
                        self.wishlistedBooks = []
                        for doc in docs {
                            do {
                                let book = try doc.data(as: Book.self)
                                self.wishlistedBooks.append(book)
                            } catch let convertError {
                                print("Conversion Error: \(convertError.localizedDescription)")
                            }
                        }
                        
                        self.wishlistedBooks.sort(by: {$0.title < $1.title})
                    }
                }
        }
    }
    
    private func loadAlreadyReadBooks() {
        if let user = auth.currentUser {
            // Load Already Read
            firestore
                .collection("alreadyRead")
                .whereField("readerID", isEqualTo: user.uid)
                .addSnapshotListener { querySnapshot, error in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    if let snapshot = querySnapshot {
                        let docs = snapshot.documents
                        self.alreadyReadBooks = []
                        for doc in docs {
                            do {
                                let book = try doc.data(as: Book.self)
                                self.alreadyReadBooks.append(book)
                            } catch let convertError {
                                print("Conversion Error: \(convertError.localizedDescription)")
                            }
                        }
                        
                        self.alreadyReadBooks.sort(by: {$0.title < $1.title})
                    }
                }
        }
    }
    
    private func loadSearchHistory() {
        if let user = auth.currentUser {
            firestore
                .collection("private")
                .document(user.uid)
                .addSnapshotListener { snapshot, error in
                    if let data = snapshot?.data(), let history = data["searchHistory"] as? [NSDictionary] {
                        var convHistory = [SearchTerm]()
                        for term in history {
                            convHistory.append(SearchTerm(id: term["id"] as! String, date: (term["date"] as! Timestamp).dateValue()))
                        }
                        self.searchHistory = convHistory
                    } else {
                        print("no conv")
                    }
                }
        }
    }
    
    private func loadMyNotes() {
        if let user = auth.currentUser {
            firestore
                .collection("notes")
                .whereField("creatorID", isEqualTo: user.uid)
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
                    self.myNotes = newNotes
                }
        }
    }
}
