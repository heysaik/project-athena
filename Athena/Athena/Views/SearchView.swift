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
    @State private var searchTerm = ""
    private let booksManager = GoogleBooksManager.shared
    @State private var bookResults = [Book]()
    @State private var searchHistory = [SearchTerm]()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    if searchTerm.isEmpty {
                        VStack(spacing: 16) {
                            Text("Search History")
                                .font(.headline)
                            ForEach(searchHistory, id: \.self) { term in
                                Button {
                                    searchTerm = term.id
                                } label: {
                                    Text(term.id)
                                        .foregroundColor(.white)
                                }
                                .tint(.white)
                            }
                        }
                    } else {
                        ScrollView {
                            if bookResults.count == 0 {
                                Text("No results")
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(bookResults) { book in
                                        NavigationLink {
                                            DetailView(book: book, type: .fromSearch)
                                        } label: {
                                            VStack(alignment: .leading) {
                                                HStack {
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
                                                            .lineLimit(1)
                                                            .multilineTextAlignment(.leading)
                                                        Text(book.description)
                                                            .font(.body)
                                                            .lineLimit(2)
                                                            .multilineTextAlignment(.leading)
                                                        HStack {
                                                            Text(book.authors.formatted(.list(type: .and)))
                                                            Spacer()
                                                            Text("\(book.pageCount) pages")
                                                        }
                                                        .font(.caption.italic())
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
                .onChange(of: searchTerm) { term in
                    Task {
                        self.bookResults = try await booksManager.search(term.replacingOccurrences(of: " ", with: "+"))
                    }
                }
            }
            .navigationTitle("Search")
            .tint(.white)
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
            .onAppear {
                Task {
                    Firestore.firestore()
                        .collection("private")
                        .document(Auth.auth().currentUser!.uid)
                        .addSnapshotListener { snapshot, error in
                            if let data = snapshot?.data(), let history = data["history"] as? [[Any: Any]] {
                                let convHistory = [SearchTerm]()
                                for history in history {
                                    convHistory.append(SearchTerm(id: history["id"], date: history["date"]))
                                }
                                searchHistory = convHistory
                            } else {
                                print("no conv")
                            }
                        }
                }
            }
            .onSubmit(of: .search) {
                Task {
                    let ref = Firestore.firestore()
                        .collection("private")
                        .document(Auth.auth().currentUser!.uid)
                    let doc = try await ref.getDocument()
                    if let data = doc.data(), let history = data["searchHistory"] as? [SearchTerm] {
                        
                        var sortedHistory = history.sorted {$0.date > $1.date}
                        if sortedHistory.contains(where: {$0.id == searchTerm}) {
                            sortedHistory.removeAll(where: {$0.id == searchTerm})
                        } else {
                            if sortedHistory.count > 4 {
                                sortedHistory.removeLast()
                            }
                        }
                        sortedHistory.insert(SearchTerm(id: searchTerm, date: Date()), at: 0)
                        
                        try await ref
                            .updateData([
                                "searchHistory": sortedHistory.map { $0.convertToDict() }
                            ])
                    }
                }
            }
        }
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
