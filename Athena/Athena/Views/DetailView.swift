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

struct DetailView: View {
    @State private var inLibrary = false
    @State private var recommendedBooks = [Book]()
    
    private let booksManager = GoogleBooksManager.shared
    
    var book: Book
    
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
                            StarsView(rating: book.googleBooksRating)
                                .foregroundColor(Color.yellow)
                        }
                    }
                    
                    if inLibrary {
                        // TODO: Progress Circle
                        
                        // Buttons
                        HStack {
                            // TODO: Mark as Completed Button
                            
                            // TODO: Update Progress Button
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button {
                                if !inLibrary {
                                    // Add to Library
                                    let gen = UINotificationFeedbackGenerator()
                                    
                                    Task {
                                        if let convertedBook = book.convertToDict() {
                                            try await Firestore.firestore()
                                                .collection("users")
                                                .document(Auth.auth().currentUser!.uid)
                                                .updateData([
                                                    "currentlyReading": FieldValue.arrayUnion([
                                                        convertedBook
                                                    ])
                                                ])
                                            gen.notificationOccurred(.success)
                                        } else {
                                            // Print Error
                                            gen.notificationOccurred(.error)
                                        }
                                    }
                                }
                            } label: {
                                Label(inLibrary ? "Added to Library" : "Add to Library", systemImage: inLibrary ? "checkmark.circle.fill" : "plus.circle.fill")
                                    .font(.system(size: 18, weight: .bold, design: .default))
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
                    }
                    
                    // Book Description
                    Text(book.description)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 17, weight: .medium, design: .default))
                        .lineLimit(10)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.black.opacity(0.25))
                        )
                    
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
        .onAppear {
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
                        
                        if data.currentlyReading.contains(book) || data.alreadyRead.contains(book) || data.wishlist.contains(book) {
                            inLibrary = true
                        } else {
                            inLibrary = false
                        }
                    } catch {
                        print("error failed")
                    }
                }
            
            if book.authors.count > 0 {
                Task {
                    var booksFromAuthor = try await booksManager.recommendedBooks(from: book.authors.first!)
                    booksFromAuthor.removeAll(where: {$0.id == self.book.id})
                    self.recommendedBooks = booksFromAuthor
                }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(book: Book(id: "", title: "", authors: [], publisher: "", publishedDate: "", description: "", pageCount: 0, categories: [], imageLink: "", googleBooksRating: 5))
    }
}
