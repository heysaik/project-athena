//
//  TextEditView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI

enum TextContentType {
    case note
    case review
}

enum ContentActionType {
    case create
    case update
}

struct TextEditView: View {
    // Private Variables
    @Environment(\.presentationMode) var presentationMode
    @State private var currentlyReadingBooks = [Book]()
    @State private var selectedBookTitle: String? = nil
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    private let gen = UINotificationFeedbackGenerator()
    
    // Initialized Variables
    @Binding var note: Note
    @Binding var book: Book
    var contentType: TextContentType = .note
    var actionType: ContentActionType = .update
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                if contentType == .note {
                    TextField("Title", text: $note.title)
                        .font(.custom("FoundersGrotesk-Bold", size: 24))
                        .foregroundColor(.white)
                    CustomTextEditor(placeholder: "Start typing...", text: $note.note)
                        .font(.custom("FoundersGrotesk-Regular", size: 17))
                } else {
                    CustomTextEditor(placeholder: "Start typing...", text: $book.userReview ?? "")
                        .font(.custom("FoundersGrotesk-Regular", size: 17))
                }
                Spacer()
                
                if contentType == .note {
                    VStack(alignment: .leading, spacing: 8) {
                        Menu {
                            Picker("", selection: $selectedBookTitle) {
                                Section {
                                    Text("No Book")
                                        .tag(String?.none)
                                }
                                ForEach(currentlyReadingBooks) { book in
                                    Text(book.title)
                                        .tag(String?.some(book.title))
                                }
                            }
                        } label: {
                            Text(note.book == nil ? "Tap to Link a Book" : "Linked Book")
                                .titleTwo()
                                .foregroundColor(.white)
                        }
                        .onChange(of: selectedBookTitle) { title in
                            self.note.book = self.currentlyReadingBooks.first(where: {$0.title == title})!
                        }
                        
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
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction, content: {
                Button {
                    if contentType == .note {
                        // Note Content Type
                        Task {
                            if actionType == .create {
                                // Create Note
                                try await createNote(note: note)
                            } else {
                                // Update Note
                                try await updateNote(note: note)
                            }
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        // Review Content Type
                        Task {
                            try await addReview()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    Text("Save")
                        .headline()
                }
            })
        }
        .navigationTitle(contentType == .note ? (actionType == .create ? "Create New Note" : "Update Note") : (actionType == .create ? "Add Review" : "Update Review"))
        .onAppear {
            // If creating a new note, set it to empty
            if actionType == .create {
                self.note = Note(title: "", note: "", createdAt: Date(), creatorID: Auth.auth().currentUser!.uid, editedAt: Date())
            }
            
            // Load Library of Currently Reading
            if contentType == .note {
                if let user = auth.currentUser {
                    firestore
                        .collection("currentlyReading")
                        .whereField("readerID", isEqualTo: user.uid)
                        .getDocuments(completion: { snapshot, error in
                            guard error == nil else {
                                print(error!.localizedDescription)
                                return
                            }
                            
                            if let snapshot = snapshot {
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
                                self.currentlyReadingBooks.sort(by: { $0.title < $1.title })
                            }
                        })
                }
            }
        }
    }
    
    private func createNote(note: Note) async throws {
        do {
            try await firestore
                .collection("notes")
                .document()
                .setData([
                    "title": note.title,
                    "note": note.note,
                    "createdAt": note.createdAt,
                    "creatorID": note.creatorID,
                    "editedAt": note.editedAt,
                    "book": note.book?.convertToDict()
                ])
        } catch let addError {
            print(addError.localizedDescription)
        }
    }
    
    private func updateNote(note: Note) async throws {
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
                        "editedAt": note.editedAt,
                        "book": note.book?.convertToDict()
                    ])
            }
        } catch let addError {
            print(addError.localizedDescription)
        }
    }
    
    private func addReview() async throws {
        do {
            try await Firestore.firestore()
                .collection("alreadyRead")
                .document(book.docID)
                .updateData(["userReview": book.userReview ?? ""])
            await gen.notificationOccurred(.success)
        } catch let addError {
            print(addError.localizedDescription)
            await gen.notificationOccurred(.error)
        }
    }
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
