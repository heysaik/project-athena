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

enum DetailType {
    case fromSearch, fromLibrary
}

struct DetailView: View {
    var book: Book
    var type: DetailType
    @State private var inLibrary = false
    
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
                            
                            HStack {
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                            }
                            .foregroundColor(Color.yellow)
                        }
                    }
                    
                    if type == .fromSearch {
                        // Book Description
                        Text(book.description)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 17, weight: .medium, design: .default))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.black.opacity(0.25))
                            )
                        
                        // Buttons
                        HStack {
                            // Add to Library Button
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
                    } else if type == .fromLibrary {
                        // TODO: Progress Circle
                        
                        // Buttons
                        HStack {
                            // TODO: Mark as Completed Button
                            
                            // TODO: Update Progress Button
                        }
                    }
                    
                    if book.authors.count > 0 {
                        // Recommendations
                        Text("More from \(book.authors.first!)")
                            .font(.system(size: 20, weight: .semibold, design: .default))
                    }
                }
                .padding()
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
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(book: Book(id: "", title: "", authors: [], publisher: "", publishedDate: "", description: "", pageCount: 0, categories: [], imageLink: ""), type: .fromLibrary)
    }
}
