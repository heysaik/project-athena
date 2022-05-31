//
//  DetailView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/19/22.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth
import FirebaseFirestore
import AlertKit

struct DetailView: View {
    @StateObject var alertManager = CustomAlertManager()
    @EnvironmentObject var rootViewModel: RootViewModel

    @State private var currentBookLibraryType: LibraryType = .none
    @State private var showLibrarySheet = false
    @State private var recommendedBooks = [Book]()
    @State private var alertText = ""
    @State private var showInvalidProgressAlert = false
    
    private let booksManager = GoogleBooksManager.shared
    private let gen = UINotificationFeedbackGenerator()
    
    @State private var book: Book = Book(id: "", docID: "", title: "", authors: [], publisher: "", publishedDate: "", description: "", pageCount: 0, categories: [], imageLink: "")
    
    init(book: Book) {
        self._book = State(wrappedValue: book)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top) {
                        BookCoverView(imageURLString: book.imageLink)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(book.title)
                                .titleThree()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            Text(book.authors.formatted(.list(type: .and)))
                                .caption()
                                .foregroundColor(.white)
                            StarsView(rating: book.googleBooksRating ?? 0.0)
                                .foregroundColor(Color.yellow)
                            ScrollView {
                                HStack {
                                    ForEach(book.categories, id: \.self) { category in
                                        ZStack(alignment: .leading) {
//                                            RoundedRectangle(cornerRadius: 15)
//                                                .foregroundColor(.black.opacity(0.25))
                                            Text(category)
                                                .caption()
                                                .foregroundColor(.white)
                                                .padding(.top, 3)
                                                .padding(4)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .foregroundColor(.black.opacity(0.25))
                                                        .frame(height: 30)
                                                )
                                        }
                                        .frame(height: 30)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Buttons
                    if currentBookLibraryType == .reading {
                        // User is currently reading book
                        HStack {
                            // Mark Book as Completed
                            Button {
                                Task {
                                    if var convertedBook = book.convertToDict() {
                                        convertedBook["readerID"] = Auth.auth().currentUser!.uid

                                        try await Firestore.firestore()
                                            .collection("alreadyRead")
                                            .document(book.docID)
                                            .setData(convertedBook)
                                        gen.notificationOccurred(.success)
                                    } else {
                                        // Print Error
                                        gen.notificationOccurred(.error)
                                    }
                                    
                                    try await Firestore.firestore()
                                        .collection("currentlyReading")
                                        .document(book.docID)
                                        .delete()
                                    
                                    getAllBookTypes()
                                    
                                    gen.notificationOccurred(.success)
                                }
                            } label: {
                                Label("Mark as Completed", systemImage: "checkmark.circle.fill")
                                    .font(.custom("FoundersGrotesk-Medium", size: 15))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .foregroundColor(.white.opacity(0.25))
                                            .frame(height: 44)
                                    )
                                    .shadow(color: .black.opacity(0.33), radius: 10, x: 0, y: 5)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Update Progress of Book
                            Button {
                                self.alertManager.show()
                            } label: {
                                Label("Update Progress", systemImage: "circle.dashed")
                                    .font(.custom("FoundersGrotesk-Medium", size: 15))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .foregroundColor(.white.opacity(0.25))
                                            .frame(height: 44)
                                    )
                                    .shadow(color: .black.opacity(0.33), radius: 10, x: 0, y: 5)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        // Progress Circle
                        HStack {
                            Spacer()
                            ProgressCircleView(current: $book.pagesRead, total: book.pageCount)
                            Spacer()
                        }
                    } else if self.currentBookLibraryType == .alreadyRead {
                        HStack {
                            // Add/Edit Review
                            NavigationLink {
                                EditTextView(note: .constant(Note(title: "", note: "", createdAt: Date(), creatorID: Auth.auth().currentUser!.uid, editedAt: Date())), book: $book, contentType: .review, actionType: (book.userReview == nil || book.userReview == "") ? .create : .update)
                                    .environmentObject(rootViewModel)
                            } label: {
                                Label(book.userReview == nil || book.userReview == "" ? "Add your Review" : "Edit your Review", systemImage: "pencil.circle.fill")
                                    .font(.custom("FoundersGrotesk-Medium", size: 15))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .foregroundColor(.white.opacity(0.25))
                                            .frame(height: 44)
                                    )
                                    .shadow(color: .black.opacity(0.33), radius: 10, x: 0, y: 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            // Remove from Read
                            Button {
                                Task {
                                    try await Firestore.firestore()
                                        .collection("alreadyRead")
                                        .document(book.docID)
                                        .delete()
                                    self.currentBookLibraryType = .none
                                    gen.notificationOccurred(.success)
                                }
                            } label: {
                                Label("Remove from Already Read", systemImage: "rectangle.stack.fill.badge.minus")
                                    .font(.custom("FoundersGrotesk-Medium", size: 15))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .foregroundColor(.white.opacity(0.25))
                                            .frame(height: 44)
                                    )
                                    .shadow(color: .black.opacity(0.33), radius: 10, x: 0, y: 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        
                        // User Review about the Book
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Review")
                                .titleFour()
                                .foregroundColor(.white)
                            if book.userReview == nil || book.userReview == "" {
                                Text("Tap on the button above to add your thoughts about the book")
                                    .body()
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            } else {
                                NavigationLink {
                                    ZStack {
                                        LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                                            .edgesIgnoringSafeArea(.all)
                                        
                                        ScrollView {
                                            Text(book.userReview!)
                                                .body()
                                                .multilineTextAlignment(.leading)
                                                .foregroundColor(.white)
                                        }
                                        .navigationBarTitle("Your Review")
                                    }
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarTrailing, content: {
                                            Button {
                                                Task {
                                                    let gen = UINotificationFeedbackGenerator()
                                                    do {
                                                        try await Firestore.firestore()
                                                            .collection("alreadyRead")
                                                            .document(book.docID)
                                                            .updateData(["userReview": ""])
                                                        gen.notificationOccurred(.success)
                                                    } catch let addError {
                                                        print(addError.localizedDescription)
                                                        gen.notificationOccurred(.error)
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "trash")
                                            }
                                        })
                                    }
                                } label: {
                                    Text(book.userReview!)
                                        .body()
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.white)
                                        .lineLimit(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .foregroundColor(.black.opacity(0.25))
                                        )
                                }
                            }
                        }
                    } else if self.currentBookLibraryType == .wishlist {
                        HStack {
                            Spacer()
                            Button {
                                // Show Wishlist-Based Popup
                                showLibrarySheet.toggle()
                            } label: {
                                Label("In Wishlist", systemImage: "checkmark.circle.fill")
                                    .font(.custom("FoundersGrotesk-Medium", size: 15))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .foregroundColor(.white.opacity(0.25))
                                            .frame(height: 44)
                                    )
                                    .shadow(color: .black.opacity(0.33), radius: 10, x: 0, y: 5)
                            }
                            Spacer()
                        }
                    } else {
                        // Not in anything
                        HStack {
                            Button {
                                // Add to Wishlist
                                Task {
                                    if var convertedBook = book.convertToDict() {
                                        convertedBook["readerID"] = Auth.auth().currentUser!.uid

                                        try await Firestore.firestore()
                                            .collection("wishlist")
                                            .document(book.docID)
                                            .setData(convertedBook)
                                        
                                        getAllBookTypes()
                                        
                                        gen.notificationOccurred(.success)
                                    } else {
                                        // Print Error
                                        gen.notificationOccurred(.error)
                                    }
                                }
                            } label: {
                                Label("Add to Wishlist", systemImage: "cart.fill.badge.plus")
                                    .font(.custom("FoundersGrotesk-Medium", size: 15))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .foregroundColor(.white.opacity(0.25))
                                            .frame(height: 44)
                                    )
                                    .shadow(color: .black.opacity(0.33), radius: 10, x: 0, y: 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }

                            Button {
                                // Add to Library
                                self.showLibrarySheet.toggle()
                            } label: {
                                Label("Add to Library", systemImage: "rectangle.stack.fill.badge.plus")
                                    .font(.custom("FoundersGrotesk-Medium", size: 15))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .foregroundColor(.white.opacity(0.25))
                                            .frame(height: 44)
                                    )
                                    .shadow(color: .black.opacity(0.33), radius: 10, x: 0, y: 5)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                    
                    // About the Book
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .titleFour()
                            .foregroundColor(.white)
                        TextPreviewView(text: book.description, previewTitle: "About \(book.title)")
                    }
                    
                    if recommendedBooks.count > 0 {
                        // Recommendations
                        VStack(alignment: .leading, spacing: 8) {
                            Text("More from \(book.authors.first!)")
                                .titleFour()
                                .foregroundColor(.white)
                            ScrollView(.horizontal) {
                                HStack(alignment: .top, spacing: 16) {
                                    ForEach(recommendedBooks) { book in
                                        NavigationLink(destination: {
                                            DetailView(book: book)
                                        }, label: {
                                            VStack(alignment: .leading, spacing: 8) {
                                                BookCoverView(imageURLString: book.imageLink)
                                                Text(book.title)
                                                    .headline()
                                                    .lineLimit(5)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.leading)
                                                    .frame(maxHeight: .infinity, alignment: .top)
                                            }
                                            .frame(width: 104)
                                            .frame(maxHeight: .infinity)
                                        })
                                        .padding(.bottom)
                                    }
                                }
                            }
                        }
                    } else {
                        Text("No more books from \(book.authors.first!)")
                            .titleFour()
                            .foregroundColor(.white)
                            .padding(.bottom)
                    }
                }
                .padding([.horizontal, .top])
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .customAlert(manager: alertManager, content: {
            VStack {
                Text("Update Your Progress").bold()
                Text("Add the page you stopped on")
                TextField("Last Update: Page \(book.pagesRead ?? 0)", text: $alertText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
        }, buttons: [
            .cancel(content: {
                Text("Cancel")
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
            }),
            .regular(content: {
                Text("Update")
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
            }, action: {
                if let page = Int(alertText), page <= book.pageCount {
                    book.pagesRead = page
                    
                    if page == book.pageCount {
                        Task {
                            if var convertedBook = book.convertToDict() {
                                convertedBook["readerID"] = Auth.auth().currentUser!.uid
                                
                                try await Firestore.firestore()
                                    .collection("alreadyRead")
                                    .document(book.docID)
                                    .setData(convertedBook)
                                
                                try await Firestore.firestore()
                                    .collection("wishlist")
                                    .document(book.docID)
                                    .delete()
                                
                                getAllBookTypes()
                            }
                        }
                    }
                } else {
                    showInvalidProgressAlert.toggle()
                }
            })
        ])
        .confirmationDialog("Add to Library", isPresented: $showLibrarySheet, actions: {
            if currentBookLibraryType == .wishlist {
                // Remove from Wishlist
                Button(role: .destructive) {
                    Task {
                        try await Firestore.firestore()
                            .collection("wishlist")
                            .document(book.docID)
                            .delete()
                        getAllBookTypes()
                        self.currentBookLibraryType = .none
                        gen.notificationOccurred(.success)
                    }
                } label: {
                    Text("Remove from Wishlist")
                }
            }
            
            if self.currentBookLibraryType != .reading || self.currentBookLibraryType == .wishlist {
                // Add to Library
                Button {
                    Task {
                        if var convertedBook = book.convertToDict() {
                            convertedBook["readerID"] = Auth.auth().currentUser!.uid

                            try await Firestore.firestore()
                                .collection("currentlyReading")
                                .document(book.docID)
                                .setData(convertedBook)
                            
                            try await Firestore.firestore()
                                .collection("wishlist")
                                .document(book.docID)
                                .delete()
                            
                            getAllBookTypes()
                            
                            gen.notificationOccurred(.success)
                        } else {
                            // Print Error
                            gen.notificationOccurred(.error)
                        }
                    }
                } label: {
                    Text("I'm reading this")
                }
            }
            
            // Mark as Read
            Button {
                Task {
                    book.pagesRead = book.pageCount
                    if var convertedBook = book.convertToDict() {
                        convertedBook["readerID"] = Auth.auth().currentUser!.uid
                        
                        try await Firestore.firestore()
                            .collection("alreadyRead")
                            .document(book.docID)
                            .setData(convertedBook)
                        
                        try await Firestore.firestore()
                            .collection("wishlist")
                            .document(book.docID)
                            .delete()
                        
                        getAllBookTypes()
                        
                        gen.notificationOccurred(.success)
                    } else {
                        // Print Error
                        gen.notificationOccurred(.error)
                    }
                }
            } label: {
                Text("Mark as read")
            }
            
        })
        .onAppear {
            // Find out which library it is in
            getAllBookTypes()
            
            getRecommendedAuthors()
        }
        .onChange(of: book) { newBook in
            Task {
                try await updateProgress(to: book.pagesRead ?? 0)
            }
        }
        .alert("Please enter a valid value", isPresented: $showInvalidProgressAlert) {
            Button(role: .cancel) {
                
            } label: {
                Text("OK")
            }

        } message: {
            Text("Please enter a number between 0-\(book.pageCount)")
        }

    }
    
    func getRecommendedAuthors() {
        // Get recommended authors
        if book.authors.count > 0 {
            Task {
                var booksFromAuthor = try await booksManager.recommendedBooks(from: book.authors.first!)
                booksFromAuthor.removeAll(where: {$0.id == self.book.id})
                self.recommendedBooks = booksFromAuthor
            }
        }
    }
    
    func getAllBookTypes() {
        Firestore
            .firestore()
            .collection("wishlist")
            .whereField("readerID", isEqualTo: Auth.auth().currentUser!.uid)
            .whereField("id", isEqualTo: book.id)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if snapshot.documents.count == 1 {
                    do {
                        if let convBook = try snapshot.documents.first?.data(as: Book.self) {
                            self.book = convBook
                            self.currentBookLibraryType = .wishlist
                        } else {
                            print("failed conv")
                        }
                    } catch let error {
                        print("conv error: \(error.localizedDescription)")
                        return
                    }
                }
            }
        
        Firestore
            .firestore()
            .collection("alreadyRead")
            .whereField("readerID", isEqualTo: Auth.auth().currentUser!.uid)
            .whereField("id", isEqualTo: book.id)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if snapshot.documents.count == 1 {
                    do {
                        if let convBook = try snapshot.documents.first?.data(as: Book.self) {
                            self.book = convBook
                            self.currentBookLibraryType = .alreadyRead
                        } else {
                            print("failed conv")
                        }
                    } catch let error {
                        print("conv error: \(error.localizedDescription)")
                        return
                    }
                }
            }

        Firestore
            .firestore()
            .collection("currentlyReading")
            .whereField("readerID", isEqualTo: Auth.auth().currentUser!.uid)
            .whereField("id", isEqualTo: book.id)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                if snapshot.documents.count == 1 {
                    do {
                        if let convBook = try snapshot.documents.first?.data(as: Book.self) {
                            self.book = convBook
                            self.currentBookLibraryType = .reading
                        } else {
                            print("failed conv")
                        }
                    } catch let error {
                        print("conv error: \(error.localizedDescription)")
                        return
                    }
                }
            }
    }
    
    func updateProgress(to page: Int) async throws {
        book.pagesRead = page

        if self.currentBookLibraryType == .reading {
            try await Firestore
                .firestore()
                .collection("currentlyReading")
                .document(book.docID)
                .updateData([
                    "pagesRead": page
                ])
        } else if self.currentBookLibraryType == .alreadyRead {
            try await Firestore
                .firestore()
                .collection("alreadyRead")
                .document(book.docID)
                .updateData([
                    "pagesRead": page
                ])
        } else if self.currentBookLibraryType == .wishlist {
            try await Firestore
                .firestore()
                .collection("wishlist")
                .document(book.docID)
                .updateData([
                    "pagesRead": page
                ])
        } else {
            print("NOT IN ANYTHING")
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(book: Book(id: "", docID: "", title: "", authors: [], publisher: "", publishedDate: "", description: "", pageCount: 0, categories: [], imageLink: "", googleBooksRating: 5))
    }
}
