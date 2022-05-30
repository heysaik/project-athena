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

enum SortOptions {
    case title, author, progress
}

struct LibraryView: View {
    @State private var currentlyReadingBooks = [Book]()
    @State private var sortOption: SortOptions = .title
    
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
                    Text("Currently Reading")
                        .foregroundColor(.white)
                        .titleTwo()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    if currentlyReadingBooks.count == 0 {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "books.vertical")
                            Text("You are not reading any books at the moment. Go ahead and add some books to your Library")
                                .headline()
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(sortOption == .title ? (currentlyReadingBooks.sorted(by: {$0.title < $1.title})) : (sortOption == .author ? (currentlyReadingBooks.sorted(by: {$0.authors[0] < $1.authors[0]})) : (currentlyReadingBooks.sorted(by: {(Double($0.pagesRead ?? 0)/Double($0.pageCount) * 100) > (Double($1.pagesRead ?? 0)/Double($1.pageCount) * 100)})))) { book in
                                    NavigationLink {
                                        DetailView(book: book)
                                    } label: {
                                        HStack(spacing: 16) {
                                            BookCoverView(imageURLString: book.imageLink)
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(book.title)
                                                    .titleThree()
                                                    .lineLimit(1)
                                                    .multilineTextAlignment(.leading)
                                                Text(book.authors.formatted(.list(type: .and)))
                                                    .body()
                                                    .italic()
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.leading)
                                                    .opacity(0.8)
                                                HStack {
                                                    ProgressCircleView(current: .constant(book.pagesRead), total: book.pageCount, showText: false, size: 20)
                                                    Text("\(Double(book.pagesRead ?? 0)/Double(book.pageCount) * 100, specifier: "%.0f")% completed")
                                                        .caption()
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                    Menu(
                        content: {
                            Picker("", selection: $sortOption) {
                                Text("Sort by Title")
                                    .tag(SortOptions.title)
                                Text("Sort by Author")
                                    .tag(SortOptions.author)
                                Text("Sort by Progress")
                                    .tag(SortOptions.progress)
                            }
                        },
                        label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    )
                })
            }
            .tint(.white)
            .onAppear {
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
