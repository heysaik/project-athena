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
    @State private var pagesRead = 0
    
    private let booksManager = GoogleBooksManager.shared
    
    @State private var oldBooks = [Book]()
    @State private var book: Book = Book(id: "", title: "", authors: [], publisher: "", publishedDate: "", description: "", pageCount: 0, categories: [], imageLink: "")
    
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
                                    if let convertedBook = book.convertToDict() {
                                        try await Firestore.firestore()
                                            .collection("users")
                                            .document(Auth.auth().currentUser!.uid)
                                            .updateData([
                                                "alreadyRead": FieldValue.arrayUnion([
                                                    convertedBook
                                                ]),
                                                "currentlyReading": FieldValue.arrayRemove([
                                                    convertedBook
                                                ]),
                                            ])
                                        gen.notificationOccurred(.success)
                                    } else {
                                        // Print Error
                                        gen.notificationOccurred(.error)
                                    }
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
                        
                        // TODO: Progress Circle
                        HStack {
                            Spacer()
                            ProgressCircleView(current: $pagesRead, total: book.pageCount)
                            Spacer()
                        }
                    } else if inRead {
                        HStack {
                            Spacer()
                            Button {
                                let gen = UINotificationFeedbackGenerator()

                                // Remove from Read
                                Task {
                                    if let convertedBook = book.convertToDict() {
                                        try await Firestore.firestore()
                                            .collection("users")
                                            .document(Auth.auth().currentUser!.uid)
                                            .updateData([
                                                "alreadyRead": FieldValue.arrayRemove([
                                                    convertedBook
                                                ])
                                            ])
                                        gen.notificationOccurred(.success)
                                    } else {
                                        // Print Error
                                        gen.notificationOccurred(.error)
                                    }
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
                                    if let convertedBook = book.convertToDict() {
                                        try await Firestore.firestore()
                                            .collection("users")
                                            .document(Auth.auth().currentUser!.uid)
                                            .updateData([
                                                "wishlist": FieldValue.arrayUnion([
                                                    convertedBook
                                                ])
                                            ])
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
                    self.pagesRead = page
                }
            })
        ])
        .confirmationDialog("Add to Library", isPresented: $showLibrarySheet, actions: {
            if inWishlist {
                // Remove from Wishlist
                Button(role: .destructive) {
                    let gen = UINotificationFeedbackGenerator()
                    
                    Task {
                        if let convertedBook = book.convertToDict() {
                            try await Firestore.firestore()
                                .collection("users")
                                .document(Auth.auth().currentUser!.uid)
                                .updateData([
                                    "wishlist": FieldValue.arrayRemove([
                                        convertedBook
                                    ])
                                ])
                            gen.notificationOccurred(.success)
                        } else {
                            // Print Error
                            gen.notificationOccurred(.error)
                        }
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
                        if let convertedBook = book.convertToDict() {
                            try await Firestore.firestore()
                                .collection("users")
                                .document(Auth.auth().currentUser!.uid)
                                .updateData([
                                    "currentlyReading": FieldValue.arrayUnion([
                                        convertedBook
                                    ]),
                                    "wishlist": FieldValue.arrayRemove([
                                        convertedBook
                                    ])
                                ])
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
                    oldBooks.append(book)
                    book.pagesRead = book.pageCount
                    if let convertedBook = book.convertToDict() {
                        try await Firestore.firestore()
                            .collection("users")
                            .document(Auth.auth().currentUser!.uid)
                            .updateData([
                                "alreadyRead": FieldValue.arrayUnion([
                                    convertedBook
                                ])
                            ])
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
            // Set Pages Read
            self.pagesRead = book.pagesRead ?? 0
            
            // Find out which library it is in
            sortByLibrary()
            
            getRecommendedAuthors()
        }
        .onDisappear {
            Task {
                try await removeOldBooks()
            }
        }
        .onChange(of: pagesRead) { pagesRead in
            Task {
                try await updateProgress(to: pagesRead)
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
    
    func sortByLibrary() {
        Firestore
            .firestore()
            .collection("users")
            .document(Auth.auth().currentUser!.uid)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                do {
                    let data = try document.data(as: User.self)
                    
                    self.inLibrary = data.currentlyReading.contains(book)
                    self.inRead = data.alreadyRead.contains(book)
                    self.inWishlist = data.wishlist.contains(book)
                } catch let error {
                    print("Could not convert data: \(error.localizedDescription)")
                }
            }
    }
    
    func updateProgress(to page: Int) async throws {
        oldBooks.append(book)
        book.pagesRead = page

        if let convertedBook = book.convertToDict() {
            let doc = Firestore
                .firestore()
                .collection("users")
                .document(Auth.auth().currentUser!.uid)
            
            if self.inLibrary {
                try await doc.updateData([
                        "currentlyReading": FieldValue.arrayUnion([convertedBook])
                    ])
            } else if self.inRead {
                try await doc.updateData([
                        "alreadyRead": FieldValue.arrayUnion([convertedBook])
                    ])
            } else if self.inWishlist {
                try await doc.updateData([
                        "wishlist": FieldValue.arrayUnion([convertedBook])
                    ])
            } else {
                print("NOT IN ANYTHING")
            }
        } else {
            print("conv failed")
        }
    }
    
    func removeOldBooks() async throws {
        let doc = Firestore
            .firestore()
            .collection("users")
            .document(Auth.auth().currentUser!.uid)
        for book in oldBooks {
            if let convertedBook = book.convertToDict() {
                try await doc.updateData([
                    "currentlyReading": FieldValue.arrayRemove([convertedBook]),
                    "alreadyRead": FieldValue.arrayRemove([convertedBook]),
                    "wishlist": FieldValue.arrayRemove([convertedBook])
                ])
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(book: Book(id: "", title: "", authors: [], publisher: "", publishedDate: "", description: "", pageCount: 0, categories: [], imageLink: "", googleBooksRating: 5))
    }
}
