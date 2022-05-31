//
//  SearchViewModel.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class SearchViewModel: NSObject, ObservableObject {
    @Published var searchTerm = ""
    @Published var bookResults = [Book]()

    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    override init() {
        super.init()
    }
    
    public func performSearch(searchHistory: [SearchTerm]) async throws {
        let ref = Firestore.firestore()
            .collection("private")
            .document(Auth.auth().currentUser!.uid)
        var sortedHistory = searchHistory.sorted {$0.date > $1.date}
        if sortedHistory.contains(where: {$0.id == searchTerm}) {
            sortedHistory.removeAll(where: {$0.id == searchTerm})
        } else if sortedHistory.count > 4 {
            sortedHistory.removeLast()
        }
        sortedHistory.insert(SearchTerm(id: searchTerm, date: Date()), at: 0)
        
        try await ref
            .updateData([
                "searchHistory": sortedHistory.map { ["id": $0.id, "date": $0.date] }
            ])
    }
}
