//
//  SearchView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/13/22.
//

import SwiftUI
import UIKit
import SDWebImageSwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SearchView: View {
    @EnvironmentObject var rootViewModel: RootViewModel
    @StateObject var viewModel = SearchViewModel()

    private let booksManager = GoogleBooksManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.searchTerm.isEmpty {
                        VStack(spacing: 16) {
                            Text(rootViewModel.searchHistory.count != 0 ? "Search History" : "Start searching for books")
                                .headline()
                                .foregroundColor(.white)
                            ForEach(rootViewModel.searchHistory, id: \.self) { term in
                                Button {
                                    viewModel.searchTerm = term.id
                                } label: {
                                    Text(term.id)
                                        .body()
                                        .foregroundColor(.white)
                                }
                                .tint(.white)
                            }
                        }
                    } else {
                        ScrollView {
                            if viewModel.bookResults.count == 0 {
                                Text("No results")
                                    .foregroundColor(.white)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.bookResults) { book in
                                        NavigationLink {
                                            DetailView(book: book)
                                                .environmentObject(rootViewModel)
                                        } label: {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    BookCoverView(imageURLString: book.imageLink)

                                                    VStack(alignment: .leading, spacing: 8) {
                                                        Text(book.title)
                                                            .titleThree()
                                                            .lineLimit(1)
                                                            .multilineTextAlignment(.leading)
                                                        Text(book.description)
                                                            .body()
                                                            .lineLimit(2)
                                                            .multilineTextAlignment(.leading)
                                                        HStack {
                                                            Text(book.authors.formatted(.list(type: .and)))
                                                                .caption2()
                                                                .italic()
                                                            Spacer()
                                                            Text("\(book.pageCount) pages")
                                                                .caption2()
                                                                .italic()
                                                        }
                                                        .opacity(0.8)
                                                        .lineLimit(1)
                                                    }
                                                }
                                                Divider()
                                                    .foregroundColor(.white)
                                                    .opacity(0.5)
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                .onChange(of: viewModel.searchTerm) { term in
                    Task {
                        self.viewModel.bookResults = try await booksManager.search(term.replacingOccurrences(of: " ", with: "+"))
                    }
                }
            }
            .preferredColorScheme(.dark)
            .navigationTitle("Search")
            .searchable(text: $viewModel.searchTerm, placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
                Task {
                    try await viewModel.performSearch(searchHistory: rootViewModel.searchHistory)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}
