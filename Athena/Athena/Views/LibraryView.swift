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

struct LibraryView: View {
    @State private var sortOption: SortOptions = .title
    @EnvironmentObject var rootViewModel: RootViewModel

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
                    if rootViewModel.currentlyReadingBooks.count == 0 {
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
                                ForEach(rootViewModel.currentlyReadingBooks.sortBy(option: sortOption)) { book in
                                    NavigationLink {
                                        DetailView(book: book)
                                            .environmentObject(rootViewModel)
                                    } label: {
                                        HStack(spacing: 16) {
                                            BookCoverView(imageURLString: book.imageLink)
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(book.title)
                                                    .titleThree()
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
                                                        .padding(.top, 2)
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
        }
        .navigationViewStyle(.stack)
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
