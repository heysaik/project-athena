//
//  EditTextViewModel.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class EditTextViewModel: NSObject, ObservableObject {
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    private let gen = UINotificationFeedbackGenerator()

    override init() {
        super.init()
    }
    
    public func addNote(note: Note, actionType: ContentActionType) async throws {
        if let convertedBook = note.book?.convertToDict() {
            do {
                if actionType == .create {
                    try await firestore
                        .collection("notes")
                        .document()
                        .setData([
                            "title": note.title,
                            "note": note.note,
                            "createdAt": note.createdAt,
                            "creatorID": note.creatorID,
                            "editedAt": note.editedAt,
                            "book": convertedBook
                        ])
                } else if actionType == .update, let noteID = note.id {
                    try await firestore
                        .collection("notes")
                        .document(noteID)
                        .updateData([
                            "title": note.title,
                            "note": note.note,
                            "createdAt": note.createdAt,
                            "creatorID": note.creatorID,
                            "editedAt": note.editedAt,
                            "book": convertedBook
                        ])
                }
                gen.notificationOccurred(.success)
            } catch let addError {
                print(addError.localizedDescription)
                gen.notificationOccurred(.error)
            }
        } else {
            // Print Error
            gen.notificationOccurred(.error)
        }
    }
    
    public func addReview(for book: Book) async throws {
        do {
            try await firestore
                .collection("alreadyRead")
                .document(book.docID)
                .updateData(["userReview": book.userReview ?? ""])
            gen.notificationOccurred(.success)
        } catch let addError {
            print(addError.localizedDescription)
            gen.notificationOccurred(.error)
        }
    }
}
