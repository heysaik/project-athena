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

    @State private var inWishlist = false
    @State private var inLibrary = false
    @State private var inRead = false
    @State private var showLibrarySheet = false
    @State private var recommendedBooks = [Book]()
    @State private var alertText = ""
    
    private let booksManager = GoogleBooksManager.shared
    
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
                        WebImage(url: URL(string: book.imageLink))
                            .resizable()
                            .frame(width: 104, height: 157, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(6, corners: [.topLeft, .bottomLeft])
                            .cornerRadius(6, corners: [.bottomRight, .topRight])
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(book.title)
                                .font(.title3.bold())
                                .multilineTextAlignment(.leading)
                            Text(book.authors.formatted(.list(type: .and)))
                                .font(.caption)
                            StarsView(rating: book.googleBooksRating ?? 0.0)
                                .foregroundColor(Color.yellow)
                        }
                    }
                    
                    if inLibrary {
                        // Buttons
                        HStack {
                            Button {
                                // Mark as Completed
                                let gen = UINotificationFeedbackGenerator()
                                
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
                                    .font(.system(size: 15, weight: .bold, design: .default))
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
                            
                            Button {
                                self.alertManager.show()
                            } label: {
                                Label("Update Progress", systemImage: "circle.dashed")
                                    .font(.system(size: 15, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .foregroundColor(.white.opacity(0.25))
                                            .frame(height: 44)
                                    )
                                    .shadow(color: .black.opacity(0.33), radius: 10, x: 0, y: 5)
                            }
                        }
                        
                        // Progress Circle
                        HStack {
                            Spacer()
                            ProgressCircleView(current: $book.pagesRead, total: book.pageCount)
                            Spacer()
                        }
                    } else if inRead {
                        HStack {
                            Spacer()
                            Button {
                                let gen = UINotificationFeedbackGenerator()

                                // Remove from Read
                                Task {
                                    try await Firestore.firestore()
                                        .collection("alreadyRead")
                                        .document(book.docID)
                                        .delete()
                                    gen.notificationOccurred(.success)
                                }
                            } label: {
                                Label("Remove from Already Read", systemImage: "rectangle.stack.fill.badge.minus")
                                    .font(.system(size: 15, weight: .bold, design: .default))
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
                    } else if inWishlist {
                        HStack {
                            Spacer()
                            Button {
                                // Show Wishlist-Based Popup
                                showLibrarySheet.toggle()
                            } label: {
                                Label("In Wishlist", systemImage: "checkmark.circle.fill")
                                    .font(.system(size: 15, weight: .bold, design: .default))
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
                                let gen = UINotificationFeedbackGenerator()
                                
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
                                    .font(.system(size: 15, weight: .bold, design: .default))
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
                            Button {
                                // Add to Library
                                self.showLibrarySheet.toggle()
                            } label: {
                                Label("Add to Library", systemImage: "rectangle.stack.fill.badge.plus")
                                    .font(.system(size: 15, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .foregroundColor(.white.opacity(0.25))
                                            .frame(height: 44)
                                    )
                                    .shadow(color: .black.opacity(0.33), radius: 10, x: 0, y: 5)
                            }
                        }
                    }
                    
                    // Book Description
                    NavigationLink {
                        ZStack {
                            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                                .edgesIgnoringSafeArea(.all)
                            
                            ScrollView {
                                Text(book.description)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 17, weight: .medium, design: .default))
                                    .padding()
                            }
                            .navigationBarTitle("About the Book")
                        }
                    } label: {
                        Text(book.description)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 17, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .lineLimit(10)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.black.opacity(0.25))
                            )
                    }
                    
                    if recommendedBooks.count > 0 {
                        // Recommendations
                        VStack(alignment: .leading, spacing: 16) {
                            Text("More from \(book.authors.first!)")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                            
                            ScrollView(.horizontal) {
                                HStack(alignment: .top, spacing: 16) {
                                    ForEach(recommendedBooks) { book in
                                        NavigationLink(destination: {
                                            DetailView(book: book)
                                        }, label: {
                                            VStack(alignment: .leading, spacing: 8) {
                                                WebImage(url: URL(string: book.imageLink))
                                                    .resizable()
                                                    .frame(width: 104, height: 157, alignment: .center)
                                                    .aspectRatio(contentMode: .fill)
                                                    .cornerRadius(3, corners: [.topLeft, .bottomLeft])
                                                    .cornerRadius(10, corners: [.bottomRight, .topRight])
                                                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                                                Text(book.title)
                                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.leading)
                                                    .frame(maxHeight: .infinity)
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
                            .font(.system(size: 20, weight: .semibold, design: .default))
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
            }),
            .regular(content: {
                Text("Update")
            }, action: {
                if let page = Int(alertText) {
                    book.pagesRead = page
                }
            })
        ])
        .confirmationDialog("Add to Library", isPresented: $showLibrarySheet, actions: {
            if inWishlist {
                // Remove from Wishlist
                Button(role: .destructive) {
                    let gen = UINotificationFeedbackGenerator()
                    
                    Task {
                        try await Firestore.firestore()
                            .collection("wishlist")
                            .document(book.docID)
                            .delete()
                        gen.notificationOccurred(.success)
                    }
                } label: {
                    Text("Remove from Wishlist")
                    
                }
            }
            
            if !inLibrary || inWishlist {
                // Add to Library
                Button {
                    let gen = UINotificationFeedbackGenerator()
                    
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
                let gen = UINotificationFeedbackGenerator()
                
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
                            print(convBook)
                            self.book = convBook
                            
                            self.inWishlist = true
                            self.inRead = false
                            self.inLibrary = false
                        } else {
                            print("failed conv")
                        }
                    } catch let error {
                        print("conv error: \(error.localizedDescription)")
                        return
                    }
                } else {
                    self.inWishlist = false
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
                            print(convBook)
                            self.book = convBook
                            
                            self.inWishlist = false
                            self.inRead = true
                            self.inLibrary = false
                        } else {
                            print("failed conv")
                        }
                    } catch let error {
                        print("conv error: \(error.localizedDescription)")
                        return
                    }
                } else {
                    self.inRead = false
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
                            print(convBook)
                            self.book = convBook
                            
                            self.inWishlist = false
                            self.inRead = false
                            self.inLibrary = true
                        } else {
                            print("failed conv")
                        }
                    } catch let error {
                        print("conv error: \(error.localizedDescription)")
                        return
                    }
                } else {
                    self.inLibrary = false
                }
            }
    }
    
    func updateProgress(to page: Int) async throws {
        book.pagesRead = page

        if self.inLibrary {
            try await Firestore
                .firestore()
                .collection("currentlyReading")
                .document(book.docID)
                .updateData([
                    "pagesRead": page
                ])
        } else if self.inRead {
            try await Firestore
                .firestore()
                .collection("alreadyRead")
                .document(book.docID)
                .updateData([
                    "pagesRead": page
                ])
        } else if self.inWishlist {
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
