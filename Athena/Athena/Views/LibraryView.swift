//
//  LibraryView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/13/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI
import CollectionViewPagingLayout

struct LibraryView: View {
    @State private var currentlyReadingBooks = [Book]()
    @State private var selectedBookID: Book.ID? = nil

    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                LinearGradient(
                    colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)],
                    startPoint: .topLeading,
                    endPoint: .center
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Currently Reading")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if currentlyReadingBooks.count == 0 {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "books.vertical")
                            Text("You are not reading any books at the moment. Go ahead and add some books to your Library")
                                .font(.system(size: 19, weight: .semibold, design: .default))
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        Spacer()
                    } else {
                        VStack(alignment: .center, spacing: 24) {
                            StackPageView(currentlyReadingBooks, selection: $selectedBookID) { book in
                                Button {
                                    // Open Album
                                } label: {
                                    NavigationLink {
                                        DetailView(book: book)
                                    } label: {
                                        WebImage(url: URL(string: book.imageLink))
                                            .resizable()
                                            .aspectRatio(0.66, contentMode: .fit)
                                            .frame(width: geometry.size.width * 0.9)
                                            .cornerRadius(5, corners: [.topLeft, .bottomLeft])
                                            .cornerRadius(13, corners: [.bottomRight, .topRight])
    //                                        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                                    }
                                    .buttonStyle(FlatLinkStyle())
                                    .aspectRatio(0.66, contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.9)
                                }
                            }
                            .options(StackTransformViewOptions.layout(.perspective))

                            VStack(alignment: .center, spacing: 8) {
                                Text(currentlyReadingBooks.first { $0.id == selectedBookID ?? "" }?.title ?? "")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold, design: .default))

                                Text((currentlyReadingBooks.first { $0.id == selectedBookID ?? "" }?.authors ?? []).formatted(.list(type: .and)))
                                    .font(.system(size: 16, weight: .light, design: .default))
                                    .foregroundColor(.white)
                                
                                // TODO: Progress View
                                
                                // TODO: We can add this when we get to ratings
    //                            ForEach(0..<5) { i in
    //                                Image(systemName: "star.fill")
    //                                    .font(.system(size: 16))
    //                                    .foregroundColor(.yellow)
    //                            }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Library")
            .tint(.white)
            .onAppear {
                if let user = auth.currentUser {
                    firestore
                        .collection("users")
                        .document(user.uid)
                        .addSnapshotListener { docSnapshot, error in
                            guard error == nil else {
                                print(error!.localizedDescription)
                                return
                            }
                            
                            if let snapshot = docSnapshot {
                                do {
                                    let userData = try snapshot.data(as: User.self)
                                    self.currentlyReadingBooks = userData.currentlyReading.sorted(by: {$0.title < $1.title})
                                    if self.currentlyReadingBooks.count > 0 {
                                        self.selectedBookID = currentlyReadingBooks.first!.id
                                    }
                                } catch let convertError {
                                    print("Conversion Error: \(convertError.localizedDescription)")
                                }
                            }
                        }
                }
            }
        }
        
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}

struct FlatLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
