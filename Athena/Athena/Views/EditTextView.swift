//
//  EditTextView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI

struct EditTextView: View {
    // Private Variables
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject private var viewModel = EditTextViewModel()

    @State private var selectedBookTitle: String? = nil
    
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
                                ForEach(rootViewModel.currentlyReadingBooks) { book in
                                    Text(book.title)
                                        .tag(String?.some(book.title))
                                }
                            }
                        } label: {
                            Text(note.book == nil ? "Tap to Link a Book" : "Linked Book (tap to change)")
                                .titleTwo()
                                .foregroundColor(.white)
                        }
                        .onChange(of: selectedBookTitle) { title in
                            self.note.book = rootViewModel.currentlyReadingBooks.first(where: {$0.title == title})!
                        }
                        
                        if note.book != nil {
                            Text(note.book!.title)
                                .titleThree()
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                            try await viewModel.addNote(note: note, actionType: actionType)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        // Review Content Type
                        Task {
                            try await viewModel.addReview(for: book)
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
        }
    }
}
